#!/usr/local/bin/python

#merge cnvnator output
import os
import sys
from optparse import OptionParser

##########
## Add functions definition to avoid imports
#sort
def sort_list(x,y):
        return cmp(x,y)

##########
#code to calculate reciprocal overlap
def reciprocal_overlap(s_1,e_1,s_2,e_2):
	if s_2 > e_1 or s_1 > e_2:
		return [0,0]
	else:
		#get the smaller start
		if s_2 >=s_1:
			o_start = s_2
		else:
			o_start = s_1
		#get the smaller end
		if e_2 >= e_1:
			o_end = e_1
		else:
			o_end = e_2

		#calculate length of call and length of overlap
		s1_len = e_1 - s_1
		s2_len = e_2 - s_2
		o_len = o_end - o_start

		if 100 * o_len / (s1_len * 1.0) < 0 or 100 * o_len / (s2_len * 1.0) < 0:
			print( "s_1: ", s_1, "e_1: ",e_1, "s_2:", s_2, "e_2:", e_2, "o_start:", o_start, "o_end:", o_end)
			print ("s1_len: ", s1_len, "s2_len: ", s2_len, " o_len: ", o_len, "% s1 length overlap: ", 100 * o_len / (s1_len * 1.0), "% s2 length overlap: ", 100 * o_len / (s2_len * 1.0))
			sys.exit(0)

		#return the percent overlap
		return [100 * o_len / (s1_len * 1.0),100 * o_len / (s2_len * 1.0)]

##########
#merge overlappping regions into cluster, note that the start and end of the cluster are trimmed
def cluster(o_data,c_data,ref_start,ref_end):
    START = 0
    END = 0
    clusterString = ""
    #for all regions
    for data in o_data:
        start = data[0]
        end = data[1]
        region = str(start) +"-"+str(end)+","
        if START == 0 and END == 0:
            START = start
            END = end
            clusterString += region
            continue
        elif start <= END:
            clusterString += region
            #now we have a new cluster end
            if end > END:
                END = end
        #region doesn't overlap with the cluster
        else:
            if START < ref_start:
                START = ref_start
            if END > ref_end:
                END = ref_end
            c_data.append([START,END])
            #start new cluster
            clusterString = region
            START = start
            END = end
    #the last cluster details
    if clusterString != "":
        if START < ref_start:
            START = ref_start
        if END > ref_end:
            END = ref_end
        c_data.append([START,END])

##########
#merge overlappping regions into cluster, no start and end cluster trimming
def alt_cluster(o_data,c_data):
    START = 0
    END = 0
    clusterString = ""
    #for all regions
    for data in o_data:
        start = data[0]
        end = data[1]
        region = str(start)+"-"+str(end)+","
        if START == 0 and END == 0:
            START = start
            END = end
            clusterString += region
            continue
        elif start <= END:
            clusterString += region
            #now we have a new cluster end
            if end > END:
                END = end
        #region doesn't overlap with the cluster
        else:
            c_data.append([START,END])
            #start new cluster
            clusterString = region
            START = start
            END = end
    #the last cluster details
    if clusterString != "":
        c_data.append([START,END])

##########
#code to calculate overlap
def overlap(s_1,e_1,s_2,e_2):
  if s_2 > e_1 or s_1 > e_2:
    return [0,0]
  else:
    #get the smaller start
    if s_2 >=s_1:
      o_start = s_2
    else:
      o_start = s_1
    #get the smaller end
    if e_2 >= e_1:
      o_end = e_1
    else:
      o_end = e_2

    #calculate length of call and length of overlap
    s1_len = e_1 - s_1
    s2_len = e_2 - s_2
    o_len = o_end - o_start

    if 100 * o_len / (s1_len * 1.0) < 0 or 100 * o_len / (s2_len * 1.0) < 0:
      print ("s_1: ", s_1, "e_1: ",e_1, "s_2:", s_2, "e_2:", e_2, "o_start:", o_start, "o_end:", o_end)
      print ("s1_len: ", s1_len, "s2_len: ", s2_len, " o_len: ", o_len, "% s1 length overlap: ", 100 * o_len / (s1_len * 1.0), "% s2 length overlap: ", 100 * o_len / (s2_len * 1.0))
      sys.exit(0)

    #return the percent boundary
    return [o_start,o_end]

##########
#find overlap between list of intervals and the region
def find_overlap(intervals,start,end):
  boundaries = []
  c_boundaries = []
  for i in intervals:
    ovlp = overlap(i[0],i[1],start,end)
    if ovlp == [0,0]:
      continue
    else:
      boundaries.append(ovlp)

  boundaries.sort(sort_list)
  cluster(boundaries,c_boundaries,start,end)
  covered = 0
  for c in c_boundaries:
    covered += c[1]-c[0]+1

  return (covered/((end-start+1)*1.0))*100

##########
#find overlap between list of calls and the region
def find_overlap_calls(calls,start,end):
  boundaries = []
  c_boundaries = []
  for i in calls:
    ovlp = overlap(i.get_start(),i.get_end(),start,end)
    if ovlp == [0,0]:
      continue
    else:
      boundaries.append(ovlp)

  boundaries.sort(sort_list)
  cluster(boundaries,c_boundaries,start,end)

  covered = 0
  for c in c_boundaries:
    covered += c[1]-c[0]+1

  return (covered/((end-start+1)*1.0))*100


#hard coded cutoffs
GAP_LEN_CUTOFF = 70
GAP_CUTOFF = 90
CNV_CUTOFF = 30
LEN_CUTOFF = 70
RATIO_CUTOFF = 10

header = ["#sample","chrm","start","end","cnv","size","normalized_rd","e-val2","q0"]

parser = OptionParser ( )
parser.add_option ( '-i', dest='input_dir', help='Directory with ERDS CNV calls')
parser.add_option ( '-a', dest='alt_file', default=None, help='alt ids = two columns')
parser.add_option ( '-o', dest='out_dir', default="output", help='file to write to')
parser.add_option ( '-g', dest='gap_file', default=None, help='gaps file')

(options, args) = parser.parse_args()
input_dir = options.input_dir
alt_file = options.alt_file
out_dir = options.out_dir
gap_file = options.gap_file

debug=open("cnvn.merge.log",'w')
alt = 0
#read options
if input_dir == None:
  print ("Please specify the path to CNVNATOR CNV call directory ...")
  sys.exit(1)
else:
  if not os.path.isdir(input_dir):
    print ("Path to CNVNATOR CNV call directory not found ...")
    sys.exit(1)

if alt_file == None:
  print ("Alternate names not specified...")
  sys.exit(1)
else:
  if not os.path.isfile(alt_file):
    print ("File with alt names not found ...")
    sys.exit(1)

if gap_file == None:
  print ("File with gaps not specified...")
  sys.exit(1)
else:
  if not os.path.isfile(gap_file):
    print ("File with gaps not found ...")
    sys.exit(1)

######################################################
#define class to hold the call details
######################################################
class call_details:
	#initial state
	def __init__(self, chrm, start, end , cnv, qz, nrd, id):
		self.chrm = chrm
		self.start = start
		self.end = end
		self.cnv = cnv
		self.qz = qz
		self.nrd = nrd
		self.id = id
	#get functions
	def get_chrm(self):
		return self.chrm
	def get_start(self):
		return self.start
	def get_end(self):
		return self.end
	def get_cnv(self):
		return self.cnv
	def get_qz(self):
		return self.qz
	def get_nrd(self):
		return self.nrd
	def get_id(self):
		return self.id
	def get_size(self):
		return self.end-self.start+1
	#print contents
	def print_call(self):
		print (self.chrm, self.start, self.end, self.cnv, self.qz, self.nrd, self.id)

######################################################
#define class to hold the clusters
######################################################
class cluster_details:
	#initial state
	def __init__(self, chrm, start, end , cnv, num_var, len_var, len_gap, nrd_tag):
		self.chrm = chrm
		self.start = start
		self.end = end
		self.cnv = cnv
		self.num_var = num_var
		self.len_var = len_var
		self.len_gap = len_gap
		self.nrd_tag={}
		self.nrd_tag[nrd_tag]=1
		self.calls = []
	#get functions
	def get_chrm(self):
		return self.chrm
	def get_start(self):
		return self.start
	def get_end(self):
		return self.end
	def get_cnv_type(self):
		return cnv
	def get_cnv(self):
		return self.cnv
	def get_num_var(self):
		return self.num_var
	def get_len_var(self):
		return self.len_var
	def get_len_gap(self):
		return self.len_gap
	def get_nrd_tag(self):
		return "|".join(self.nrd_tag.keys())
	def get_size(self):
		return self.end - self.start + 1
  #set functions
	def set_start(self,new_start):
		self.start = new_start
	def set_end(self,new_end):
		self.end = new_end
	def set_num_var(self,n_v):
		self.num_var += n_v
	def set_len_var(self,n_l):
		self.len_var += n_l
	def set_len_gap(self,n_g):
		self.len_gap += n_g
	def set_nrd_tag(self,tag):
		self.nrd_tag[tag]=1
	def add_call(self, call):
		self.calls.append(call)
	def get_calls(self):
		return self.calls
	def get_call_len(self):
		return len(self.calls)

	#print cluster details as a string
	def print_calls(self):
		str_temp = self.chrm + "*" +   str(self.start) + "*" + str(self.end) + "*" + self.cnv + "*" + str(self.num_var) + "*" + str(self.len_var) + "*" + str(self.len_gap) + "*" + "|".join(self.nrd_tag.keys()) + "##"
		for f in range(0, len(self.calls)):
			str_temp += str(f+1) + "|" +  self.calls[f].get_chrm() + "|" + str(self.calls[f].get_start()) + "|" + str(self.calls[f].get_end()) + "|" +  self.calls[f].get_cnv() + ", "

		str_temp = str_temp[:-2]
		return str_temp

###################################
#read alternate ids
alt = open(alt_file)
alt_name = {}
for line in alt:
	line = line.replace("\n","")
	words = line.split("\t")
	if not words[0] in alt_name:
		alt_name[words[0]] = words[1]
	else:
		print( "Duplicate entry for sample ", words[0])
		sys.exit(0)
alt.close()

###################################
#read gaps
gap_pos =  open(gap_file)
gaps = {}
for line in gap_pos:
	line = line.replace("\n","")
	words = line.split("\t")
	chrm = words[0].replace("chr","")
	if chrm in gaps:
	  gaps[chrm].append([int(words[1]),int(words[2]),words[3]])
	else:
		gaps[chrm]=[[int(words[1]),int(words[2]),words[3]]]
gap_pos.close()

###################################
#read cnv files
samples = os.listdir(input_dir)
flag = 0
header_index = {}
h_flag = 0
complete = 1
for sample in samples:
  sample_name = sample.replace(".CNVnator.wg.bin500.calls.filtered.txt","")

  #replace ID with alt_id
  if sample_name in alt_name:
    sample_name=alt_name[sample_name]

  s_file = input_dir+"/*"+sample
  t_file_name = sample_name + ".temp"

  #sort call file based on the chr, start and end position, remove comments also
  command = "sort -k5,5 -k2,2 -k3,3n -k4,4n " + s_file + " | grep -v \"^>\" > " + t_file_name
  os.system(command)

  t_file = open(t_file_name)
  cnvs = {}

  for line in t_file:
    line = line.replace("\n","")
    words = line.split("\t")
    if len(words) < 2:
      continue
    if line[0] == "#" or len(words) < 2:
      continue
    else:
      if line[0] == ">":
        #add check later
        continue
      else:
        #sample chrm    start   end     cnv     size    normalized_rd   e-val2  q0
        #format check
        try:
          chrm = words[1].replace("chr","")
          start = int(words[2])
          end = int(words[3])
          cnv = words[4]
          qz = words[8]
          nrd = words[6]
          id = chrm + "|" + str(start) + "|" + str(end) + "|" + cnv

        except ValueError:
          print ("Error... Check file format")
          print ("Cloumns 3 and 4 should be numeric")
          sys.exit(0)

        if chrm in cnvs:
          if cnv in cnvs[chrm]:
            cnvs[chrm][cnv].append(call_details(chrm,start,end,cnv,qz,nrd,id))
          else:
            cnvs[chrm][cnv]=[call_details(chrm,start,end,cnv,qz,nrd,id)]
        else:
          cnvs[chrm]={cnv:[call_details(chrm,start,end,cnv,qz,nrd,id)]}
  t_file.close()

  merged = {}
  calls_to_cluster = []

  for c in cnvs.keys():
    for d in cnvs[c].keys():
      temp_calls_to_cluster = []
      temp = []
      interval_size = 0
      #used to check of there are calls in the other direction in the intervals
      other = "DEL"
      if d == "DEL":
        other = "DUP"
      # iterate through the CNVs and cluster the ones that statisfy the coditions required for clustering
      #1. the interval between CNVs overlaps gaps by > GAP_CUTOFF
      #2. the interval has CNVs < CNV_CUTOFF in the opposite direction
      #3. the (sum of the CNV lengths / length of merged CNV) % > LEN_CUTOFF
      for s in range(0,len(cnvs[c][d])-1):
        s1=cnvs[c][d][s]
        s2=cnvs[c][d][s+1]

        int_start = s1.get_end()
        int_end = s2.get_start()
        int_size = int_end - int_start

        #GAP
        gap_ovlp = functions.find_overlap(gaps[c], int_start, int_end)
        #OPPOSITE CNV
        if cnvs.has_key(c):
          if cnvs[c].has_key(other):
            other_cnv = cnvs[c][other]
          else:
            other_cnv = []
        else:
          other_cnv = []
        opp_ovlp = functions.find_overlap_calls(other_cnv, int_start, int_end)
        #cnv fraction
        cnv_fraction = ((s1.get_size() + s2.get_size() + 1)/((s2.get_end()-s1.get_start() + 1)*1.0)) * 100
        #size fraction
        if s1.get_size() >= s2.get_size():
          size_ratio = s1.get_size()/(s2.get_size() * 1.0)
        else:
          size_ratio = s2.get_size()/(s1.get_size() * 1.0)
        if ((gap_ovlp > GAP_CUTOFF and cnv_fraction > GAP_LEN_CUTOFF) or (opp_ovlp < CNV_CUTOFF and cnv_fraction > LEN_CUTOFF)) and (size_ratio < RATIO_CUTOFF):

          interval_size += int_size
          if not s1.get_id() in calls_to_cluster:
            calls_to_cluster.append(s1.get_id())
          if not s2.get_id() in calls_to_cluster:
            calls_to_cluster.append(s2.get_id())

          if not s1.get_id() in temp_calls_to_cluster:
            temp_calls_to_cluster.append(s1.get_id())
            temp.append(s1)
          if not s2.get_id() in temp_calls_to_cluster:
            temp_calls_to_cluster.append(s2.get_id())
            temp.append(s2)

        else:
          if len(temp)!=0:
            c_cluster = cluster_details(c,temp[0].get_start(),temp[0].get_end(),d,1,temp[0].get_size(),interval_size,temp[0].get_nrd())
            c_cluster.add_call(temp[0])

            for i in range (1,len(temp)):
              t = temp[i]
              if c_cluster.get_end() < t.get_end():
                c_cluster.set_end(t.get_end())

              c_cluster.set_num_var(1)
              c_cluster.set_len_var(t.get_size())
              c_cluster.set_nrd_tag(t.get_nrd())
              c_cluster.add_call(t)

            if merged.has_key(c):
              merged[c].append(c_cluster)
            else:
              merged[c]=[c_cluster]

          temp_calls_to_cluster = []
          temp = []
          interval_size = 0

      #last call
      if len(temp)!=0:
        c_cluster = cluster_details(c,temp[0].get_start(),temp[0].get_end(),d,1,temp[0].get_size(),interval_size,temp[0].get_nrd())
        c_cluster.add_call(temp[0])

        for i in range (1,len(temp)):
          t = temp[i]
          if c_cluster.get_end() < t.get_end():
            c_cluster.set_end(t.get_end())

          c_cluster.set_num_var(1)
          c_cluster.set_len_var(t.get_size())
          c_cluster.set_nrd_tag(t.get_nrd())
          c_cluster.add_call(t)

        if merged.has_key(c):
          merged[c].append(c_cluster)
        else:
          merged[c]=[c_cluster]

  #open file again for reading
  s_file = open(input_dir+"/"+sample)
  o_file = open(out_dir+"/"+sample+".cluster.txt",'w')
  all_id = []
  found = []
  for line in s_file:
    line = line.replace("\n","")
    words = line.split("\t")

    if line[0] == "#" or line[0] == ">":
      if h_flag == 0:
        for i in range (0,len(words)):
          header_index[words[i]] = i
        #sanity check
        for h in header:
          if not h in header_index:
            print ("Error .. Not all columns found in the file..", h)
            sys.exit(0)

        print ("\t".join(header)+"\tNum_CNVs\tLength_CNVs\tLength_Gaps\tPercent_Gap", end="\n", file = o_file)
        #h_flag = 1
      continue
    else:
      chrm = words[1].replace("chr","")
      start = int(words[2])
      end = int(words[3])
      cnv = words[4]
      id=chrm+"|"+str(start)+"|"+str(end)+"|"+cnv
      all_id.append(id)
      if not id in calls_to_cluster:
        f_line = sample_name
        for h in header:
          if h != "#sample":
            f_line =f_line + "\t" + words[header_index[h]]
          else:
            continue
        f_line += "\t-\t-\t-\t-"
        found.append(id)
        print ( f_line, end="\n", file = o_file)
      else:
        continue

  for c in merged.keys():
    for o in merged[c]:
      for call in o.get_calls():
        found.append(call.get_id())

      f_line = sample_name + "\t" + o.get_chrm() + "\t" + str(o.get_start()) + "\t" + str(o.get_end()) + "\t" + o.get_cnv() + "\t" + str(o.get_size()) + "\t" + o.get_nrd_tag() +"\t-\t-\t" + str(o.get_num_var()) + "\t" + str(o.get_len_var()) + "\t" + str(o.get_len_gap()) +"\t"+ str((o.get_len_gap()/(o.get_size()*1.0))*100)
      print ( f_line, end="\n", file = o_file)

    s_file.close()

  #Check if all CNVs are accounted for..
  missing = []
  for i in all_id:
    if i in found:
      continue
    else:
      missing.append(i)
  print (sample + "\t" + "Missing IDs: ", len(missing), end="\n", file = debug )
  if len(missing) > 0:
    complete = 0
    for i in missing:
      print (i, end="\n", file = debug)

  o_file.close()
  if complete == 0:
    print ("Error in processing sample: ", sample, end="\n", file = debug)
    sys.exit(0)
  else:
    os.system("rm " + t_file_name)
debug.close()
