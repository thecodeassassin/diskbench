
#!/bin/bash

ROOT_PATH="results"
TOTAL_WRITE=0
TOTAL_READ=0
NUM_PASS=0

for runset in `ls -1 $ROOT_PATH/`;
do
  FILE_PATH="${ROOT_PATH}/${runset}"
  for pass in `ls -1 $FILE_PATH/fio-* | awk -F'pass-' {'print \$2'} | uniq | sort | uniq`;
  do
    for file in `ls -1 $FILE_PATH/fio-*-$pass`;
    do
      cat $FILE_PATH/NAME > /dev/null
      JOB=`head -n 1 ${file} | awk -F: {'print \$1'}`
      READ_IOPS=`grep iops ${file}| grep read | awk -F'iops=' {'print \$2'} | awk {'print \$1'}`
      WRITE_IOPS=`grep iops ${file}| grep write | awk -F'iops=' {'print \$2'} | awk {'print \$1'}`
      READ_BANDWIDTH=`grep READ ${file} | awk -F'maxb=' {'print \$2'} | awk -F, {'print \$1'}`
      WRITE_BANDWIDTH=`grep WRITE ${file} | awk -F'maxb=' {'print \$2'} | awk -F, {'print \$1'}`
      
      if [ ${READ_IOPS} > 0 ] ; then
         TOTAL_READ=$(($READ_IOPS + ${TOTAL_READ}))
      fi

      if [ ${WRITE_IOPS} > 0 ] ; then
         TOTAL_WRITE=$(($WRITE_IOPS + ${TOTAL_WRITE}))
      fi

      # add one pass
      if [ ${READ_IOPS} > 0 ] || [ ${WRITE_IOPS} > 0 ]; then
        NUM_PASS=$(($NUM_PASS + 1))
      fi
    done
  done
done

echo "Total valid passes: ${NUM_PASS}"
echo "Total READ IOPS: ${TOTAL_READ}"
echo "Total WRITE IOPS: ${TOTAL_WRITE}"

echo "Average READ IOPS: $((${TOTAL_READ} / ${NUM_PASS}))"
echo "Average WRITE IOPS: $((${TOTAL_WRITE} / ${NUM_PASS}))"

