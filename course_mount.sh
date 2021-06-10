#!/bin/bash
# Create an array which holds list of courses. This should be used to compare if the course name is passed in CLI
COURSES=(
"Linux_course/Linux_course1"
"Linux_course/Linux_course2"
"SQLFundamentals1"
)
print_help () {
	echo "./course_mount.sh -h
		Usage:
			./course_mount.sh -h to print help message
			./course_mount.sh -m -c [course] for mounting a given course
			./course_mount.sh -u -c [course] for unmounting a given course
		If course name is ommited all courses will be (un)mounted"
}

#function to check mount exists
check_mount () {
    FOUND="false"                                                                           #Found means if input course is in COURSES list or not
    for COURSE in ${COURSES[@]}:
    do
          if [[ "$COURSE" == "$1" ]]
          then 
                FOUND="true"
                break
          fi
    done
    if [[ "$FOUND" == "false" ]]
    then
         echo "Course not available"
         return 2
    fi        
    echo "Found!! system checking for mount availablity"
    mount | grep "/home/user1/courses/$1" > /dev/null
    if [[ "$?" == 0 ]]
    then
         return 1
    fi
    return 0
}

#function for mount a course
mount_course () {
       echo $1
    check_mount $1
    CHECK=$?                                                      #To find return value of check_mount function
    if [[ "$CHECK" == 2 ]]
    then
           exit 2
    fi
    if [[ "$CHECK" == 1 ]]
    then
           echo "OOPS $1 is already mounted"
           exit 1
    fi
    echo " system check done starting mount "
    mkdir -p /home/user1/trainee
    sudo chown user1:user1 /home/user1/trainee
    bindfs -p 550 -u user1 -g ftpaccess /home/user1/courses/$1 /home/user1/trainee
    echo "Successfully mounted $1"

}

mount_all() {
    for COURSE in ${COURSES[@]}
    do
           mount_course $COURSE
    done
}
unmount_course() {
    check_mount $1
    CHECK=$?
    if [[ "$CHECK" == 2 ]]
    then
           exit 2
    fi
    if [[ "$CHECK" == 0 ]]
    then
          echo "Not Mounted.To Unmount Mount it first using -m option"
           exit 3
    fi
    echo "starting unmounting"
    sudo umount /home/user1/trainee
    echo "Unmounting Successful"

}
# function for unmount course
unmount_all() {
    for COURSE in ${COURSES[@]}
    do
           unmount_course $COURSE
    done
}
MOUNT_FLAG="FALSE"
UNMOUNT_FLAG="FALSE"
NOT_ALL="FALSE"
while getopts "hmuc:" arg; 
do
     case "$arg" in
        h) print_help;;
        m) MOUNT_FLAG="TRUE";;
        u) UNMOUNT_FLAG="TRUE";;
        c) NOT_ALL="TRUE";
           NAME=$OPTARG;;
        *)echo "invalid option use -h for help";;
     esac
done

if [[ "$MOUNT_FLAG" == "TRUE" ]]
then
  [ "$NOT_ALL" = "TRUE" ]&& mount_course "$NAME" && exit 0
  [ "$NOT_ALL" = "FALSE" ]&& mount_all && exit 0
fi
if [[ "$UNMOUNT_FLAG" == "TRUE" ]]
then
  [ "$NOT_ALL" = "TRUE" ]&&unmount_course "$NAME" && exit 0
  [ "$NOT_ALL" = "FALSE" ]&&unmount_all && exit 0
fi
     
