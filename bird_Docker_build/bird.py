#!/usr/bin/env python
# =========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2018 William H. Majoros (bmajoros@alumni.duke.edu)
# =========================================================================

import getopt
import os
import re
import sys
import tempfile


def generate_temp_file(suffix=""):
    fh, filename = tempfile.mkstemp(suffix)
    os.close(fh)
    return filename


DEBUG = False
WARMUP = 1000
ALPHA = 0.05
STDERR = generate_temp_file(".stderr")
INPUT_FILE = generate_temp_file(".staninputs")
INIT_FILE = generate_temp_file(".staninit")
OUTPUT_TEMP = generate_temp_file(".stanoutputs")


def printFields(fields, hFile):
    numFields = len(fields)
    for i in range(7, numFields):
        print(i - 6, "=", fields[i], sep="", end="", file=hFile)
        if i < numFields - 1:
            print("\t", end="", file=hFile)
    print(file=hFile)


def getFieldIndex(label, fields):
    numFields = len(fields)
    index = None
    for i in range(7, numFields):
        if fields[i] == label:
            index = i
    return index


def writeToFile(fields, OUT):
    numFields = len(fields)
    for i in range(7, numFields):
        print(fields[i], end="", file=OUT)
        if i < numFields - 1:
            print("\t", end="", file=OUT)
    print(file=OUT)


def writeReadCounts(fields, start, numReps, varName, OUT):
    print(varName, "<- c(", file=OUT, end="")
    for rep in range(numReps):
        print(fields[start + rep * 2], file=OUT, end="")
        if rep + 1 < numReps:
            print(",", file=OUT, end="")
    print(")", file=OUT)


def writeInitializationFile(fields, filename):
    DNAreps = int(fields[1])
    totalRef = 0
    totalAlt = 0
    for i in range(DNAreps):
        totalRef += int(fields[2 + i * 2])
        totalAlt += int(fields[3 + i * 2])
    v = float(totalAlt + 1) / float(totalAlt + totalRef + 2)
    if v == 0:
        v = 0.01
    rnaIndex = 2 + 2 * DNAreps
    RNAreps = int(fields[rnaIndex])
    OUT = open(filename, "wt")
    print(f"p <- {v}", file=OUT)
    print("theta <- 1", file=OUT)
    print("qi <- c(", file=OUT, end="")
    for i in range(RNAreps - 1):
        print(v, ",", sep="", end="", file=OUT)
    print(v, ")", sep="", file=OUT)
    OUT.close()


def writeInputsFile(fields, filename):
    DNAreps = int(fields[1])
    rnaIndex = 2 + 2 * DNAreps
    RNAreps = int(fields[rnaIndex])
    OUT = open(filename, "wt")
    print(f"N_DNA <- {DNAreps}", file=OUT)
    writeReadCounts(fields, 3, DNAreps, "a", OUT)  # alt
    writeReadCounts(fields, 2, DNAreps, "b", OUT)  # ref
    print(f"N_RNA <- {RNAreps}", file=OUT)
    writeReadCounts(fields, rnaIndex + 2, RNAreps, "k", OUT)  # alt
    writeReadCounts(fields, rnaIndex + 1, RNAreps, "m", OUT)  # ref
    OUT.close()


def getMedian(thetas):
    # Precondition: thetas is already sorted
    n = len(thetas)
    print(thetas)
    mid = int(n / 2)
    if n % 2 == 0:
        return (thetas[mid - 1] + thetas[mid]) / 2.0
    return thetas[mid]


def getCredibleInterval(thetas, alpha):
    halfAlpha = alpha / 2.0
    n = len(thetas)
    leftIndex = int(halfAlpha * n)
    rightIndex = n - leftIndex
    left = thetas[leftIndex + 1]
    right = thetas[rightIndex - 1]
    return (left, right)


def runVariant(model, fields, numSamples, outfile):
    # Write inputs file for STAN
    if len(fields) < 10:  # Not enough power?
        return None  # return (None, None) ???
    writeInputsFile(fields, INPUT_FILE)
    writeInitializationFile(fields, INIT_FILE)

    # Run STAN model
    cmd = f"{model} sample thin=1 num_samples={numSamples} num_warmup={WARMUP} data file={INPUT_FILE} init={INIT_FILE} output file={OUTPUT_TEMP} refresh=0 > {STDERR}"
    print(cmd)
    if DEBUG:
        print(cmd)
        exit()
    os.system(cmd)

    # Parse MCMC output
    thetas = []
    OUT = None if outfile == "." else open(outfile, "wt")
    with open(OUTPUT_TEMP, "rt") as IN:
        for line in IN:
            print(line)
            if len(line) == 0 or line[0] == "#":
                continue
            fields = line.rstrip().split(",")
            numFields = len(fields)
            if numFields > 0 and fields[0] == "lp__":
                if OUT is not None:
                    printFields(fields, OUT)
                thetaIndex = getFieldIndex("theta", fields)
            else:
                if OUT is not None:
                    writeToFile(fields, OUT)
                theta = float(fields[thetaIndex])
                thetas.append(theta)
    if OUT is not None:
        OUT.close()
    thetas.sort()
    return thetas


def summarize(thetas, ID, minRight):
    maxLeft = 1.0 / minRight
    n = len(thetas)
    median = getMedian(thetas)
    (CI_left, CI_right) = getCredibleInterval(thetas, ALPHA)
    reduction = 0
    increase = 0
    for i in range(n):
        if thetas[i] < maxLeft:
            reduction += 1
        if thetas[i] > minRight:
            increase += 1
    leftP = reduction / n
    rightP = increase / n
    Preg = leftP if leftP > rightP else rightP
    print(ID, median, CI_left, CI_right, Preg, sep="\t")


# =========================================================================
# main()
# =========================================================================
options, args = getopt.getopt(sys.argv[1:], "s:t:")
if len(args) != 6:
    exit(
        f"{os.path.basename(sys.argv[0])} [-s stanfile] [-t thetafile] <model> <min-effect> <input.txt> <output.txt> <#MCMC-samples> <firstVariant-lastVariant>\n   -s = save raw STAN file\n   -t = save theta samples\n   variant range is zero-based and inclusive\n   min-effect (lambda) must be >= 1\n"
    )
(model, minEffect, inFile, outfile, numSamples, numVariants) = args
stanFile = None
thetaFile = None
for pair in options:
    (key, value) = pair
    if key == "-s":
        stanFile = value
    if key == "-t":
        thetaFile = value
if not (var_range := re.search("(\d+)-(\d+)", numVariants)):
    exit(f"{numVariants}: specify range of variants: first-last")
firstIndex = int(var_range[1])
lastIndex = int(var_range[2])
minEffect = float(minEffect)
if minEffect < 1:
    raise Exception("Min-effect must be >= 1")
THETA = None
if thetaFile is not None:
    THETA = open(thetaFile, "wt")

# Process all input lines, each line = one variant (one MCMC run)
thetaIndex = None
variantIndex = 0

with open(inFile, "rt") as IN:
    for line in IN:
        print(line)
        # Check whether this variant is in the range to be processed
        if variantIndex < firstIndex:
            variantIndex += 1
            continue
        elif variantIndex > lastIndex:
            break
        fields = line.rstrip().split()
        ID = fields[0]
        thetas = runVariant(model, fields, numSamples, outfile)
        if thetas is None:
            continue
        summarize(thetas, ID, minEffect)
        variantIndex += 1
        if THETA is not None:
            for i in range(len(thetas)):
                print(thetas[i], file=THETA, end="")
                if i < len(thetas):
                    print("\t", file=THETA, end="")
            print(file=THETA)
os.remove(STDERR)
os.remove(INPUT_FILE)
if stanFile is None:
    os.remove(OUTPUT_TEMP)
else:
    os.system(f"cp {OUTPUT_TEMP} {stanFile}")
if THETA is not None:
    THETA.close()
