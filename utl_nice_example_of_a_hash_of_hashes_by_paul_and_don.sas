Nice example of a Hash of Hashes by Paul and Don;

SAS Forum
https://tinyurl.com/yah89zwd
https://communities.sas.com/t5/SAS-Communities-Library/Splitting-a-SAS-data-set-based-on-the-value-of-a-variable/ta-p/489104

Profiles
Don Henderson
https://communities.sas.com/t5/user/viewprofilepage/user-id/13569

Paul Dorfman <sashole@bellsouth.net>

I do not use the Bizarro runs data because of SAS legalise surrounding the data.
The data can only be used with SAS applications?

Hash of Hashes is most useful when the first
hash table has a grouping variiable
that can be used to the second full data hash table.


INPUT
=====

 WORK.HAVE total obs=150

   GAME     INNING     PLAYER

     1     inning_3       90
     2     inning_4       98
     3     inning_3       89
     4     inning_1      108
     5     inning_5      144
     6     inning_1      457
   ...
    27     inning_8      729
    28     inning_6      803
    29     inning_9      856
    30     inning_2      390

RULES
-----
The fist Hash table has the list of distinct innings from the data, ie innin_1-inning_9.
The second hash table has the full dataset with all the innings.
We iterate through list of innings in the first hash table and output
a dataset for each inning,

EXAMPLE OUTPUT
--------------

   Nine output datasets one per inning

   WORK.INNING_1 total obs=18

    GAME     INNING     PLAYER

      4     inning_1      108
      6     inning_1      457
      7     inning_1      906
     14     inning_1      511

   NOTE: The data set WORK.INNING_3 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_7 has 14 observations and 3 variables.
   NOTE: The data set WORK.INNING_2 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_6 has 20 observations and 3 variables.
   NOTE: The data set WORK.INNING_1 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_5 has 22 observations and 3 variables.
   NOTE: The data set WORK.INNING_9 has 11 observations and 3 variables.
   NOTE: The data set WORK.INNING_4 has 14 observations and 3 variables.
   NOTE: The data set WORK.INNING_8 has 15 observations and 3 variables.


PROCESS
=======

data _null_;
 dcl hash Innings_HoH();
 Innings_HoH.defineKey("Inning");
 Innings_HoH.defineData("Inning","Hash_Pointer");
 Innings_HoH.defineDone();
 dcl hash Hash_Pointer();

 * load the first has table with the list of innings;
 do until (dne);
    set have end=dne;
    if Innings_HoH.find() ne 0 then
    do;
       Hash_Pointer = _new_ hash(multidata:"Y");
       Hash_Pointer.defineKey("_n_");
       Hash_Pointer.defineData("game","inning", "player");
       Hash_Pointer.defineDone();
       Innings_HoH.add();
    end; /* a new inning group */
    Hash_Pointer.add();
  end;

  * iterate throuh yhr full data outputing a dataset for each inning;
  dcl hiter HoH_Iter("Innings_HoH");
  do while(HoH_Iter.next() = 0);
     Hash_Pointer.output(dataset:Inning);
  end;

run;quit;


OUTPUT
======

   NOTE: The data set WORK.INNING_3 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_7 has 14 observations and 3 variables.
   NOTE: The data set WORK.INNING_2 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_6 has 20 observations and 3 variables.
   NOTE: The data set WORK.INNING_1 has 18 observations and 3 variables.
   NOTE: The data set WORK.INNING_5 has 22 observations and 3 variables.
   NOTE: The data set WORK.INNING_9 has 11 observations and 3 variables.
   NOTE: The data set WORK.INNING_4 has 14 observations and 3 variables.
   NOTE: The data set WORK.INNING_8 has 15 observations and 3 variables.

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data have;
 do rec=1 to 5;
  do game=1 to 30;
    inning=cats("inning_",put(ceil(9*uniform(1234)),2.));
    player=ceil(1000*uniform(4321));
    output;
  end;
 end;
 drop rec;
run;quit;


