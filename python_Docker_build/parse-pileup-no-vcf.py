#!/usr/bin/env python
#=========================================================================
# This is OPEN SOURCE SOFTWARE governed by the Gnu General Public
# License (GPL) version 3, as described at www.opensource.org.
# Copyright (C)2017 William H. Majoros (martiandna@gmail.com).
#
# Adaptation by Alejandro Barrera (aebmad@gmail.com)
#=========================================================================
from __future__ import (absolute_import, division, print_function, 
   unicode_literals, generators, nested_scopes, with_statement)
from builtins import (bytes, dict, int, list, object, range, str, ascii,
   chr, hex, input, next, oct, open, pow, round, super, filter, map, zip)
# The above imports should allow this program to run in both Python 2 and
# Python 3.  You might need to update your version of module "future".
import sys
import ProgramName
import gzip
from Rex import Rex
rex=Rex()
from collections import defaultdict as dd

ACGT=["A","C","G","T"]
#QUAL="!\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJ"
#QUALITY=[-1]*256
#for i in range(len(QUAL)): QUALITY[ord(QUAL[i])]=i

def removeIndels(bases):
    while(rex.find("(\S*)[+-](\d+)(\S*)",bases)):
        left=rex[1]; indelLen=int(rex[2]); right=rex[3]
        bases=left+right[indelLen:]
    while(rex.find("(\S*)\^.(\S*)",bases)):
        bases=rex[1]+rex[2]
    while(rex.find("(\S*)\$(\S*)",bases)):
        bases=rex[1]+rex[2]
    return bases

def parseBases(bases,qual):
    bases=removeIndels(bases)
    bases=bases.upper()
    #print("AFTER:",bases)
    counts=dict(zip(ACGT, [0,0,0,0]))
    index=0
    for i in range(len(bases)):
        c=bases[i]
        if(c in ACGT):
            #if(index>=len(qual)): exit(bases+"\n"+qual+"\n"+str(index)+"\t"+c)
            #q=qual[index]
            #print(c,q,ord(q),sep="\t")
            #if(QUALITY[ord(q)]>=MIN_QUAL): counts[c]=counts.get(c,0)+1
            counts[c]+=1
            index+=1
    return counts

#=========================================================================
# main()
#=========================================================================
if(len(sys.argv)!=2):
    exit(ProgramName.get()+" <pileup.txt>\n")
(pileup,)=sys.argv[1:]

# Process the pileup file
prevChr=None
variantsOnChr=None
nextVariant=None
for line in open(pileup,"rt"):
    fields=line.split()
    if(len(fields)<6): continue
    (chr,pos,ref,total,seq,qual)=fields
    seq=seq.upper()
    pos=int(pos)-1
    ref=ref.upper()
    variantID=chr+"@"+str(pos)
    for special_character in [".", ","]:
        seq=seq.replace(special_character, ref)
    counts=parseBases(seq,qual)
#     keys=[x for x in counts.keys()]
#     if(len(keys)!=2): continue
#     alt=keys[1] if keys[0]==ref else keys[0]
#     refCount=counts.get(ref,0)
#     altCount=counts.get(alt,0)
#     print(variantID,chr,pos,ref,alt,refCount,altCount,sep="\t")
    counts_str = "\t".join([str(counts[base]) for base in ACGT])
    print(variantID,chr,pos,ACGT.index(ref)+1,counts_str,sep="\t")

