#!/bin/bash
# Author: wanghan
# Created Time : Thu 26 Jul 2018 07:37:30 PM CST
# File Name: my_dailybuild.sh
# Description:

ALARM_TIME="05:00:00"
TODAY_DATE=`date -d now +%Y%m%d`

function myprint 
{
    MYLOG_TAG="my_dailybuild"
    if [ $1 == "-r" ] ; then
        MYLOG="[`date -d today +"%Y-%m-%d %H:%M:%S"`] $MYLOG_TAG : $2"
        echo -e "\r$MYLOG\c"
    else
        echo \[`date -d today +"%Y-%m-%d %H:%M:%S"`\] $MYLOG_TAG : $*
    fi

}

function alarm_everyday 
{
    cur_date=`date -d $1 +%s`
    (( delta = `date -d now +%s` - $cur_date ))
    #echo $delta
    if [[ $delta -gt 0 ]] ; then
        if [[ $delta -gt 3600 ]] ; then
            return 0;
        else
            return 1;
        fi
    else
        return 0;
    fi
}

function alarm_update
{
    (( tmp = `date -d now +%Y%m%d` - $TODAY_DATE ))
    if [[ $tmp -gt 0 ]] ; then
        myprint "Update for alarm"
        TODAY_DATE=`date -d now +%Y%m%d`
        return 1;
    else
        return 0;
    fi
}

function daliybuild_run
{
    ### Daliybuild commands start ###
    repo sync -c --no-tags -j4
    source build/envsetup.sh
    lunch lavender-userdebug
    make -j16
    ### Daliybuild commands end ###
    if [[ $? -eq 0 ]] ; then
        return 0;
    else
        return 1;
    fi
}

function main 
{
    new_loop_flag=1
    
    while true ; do 
        
        alarm_update
        if [[ $? -eq 1 ]] ; then
            new_loop_flag=1
        fi

        if [[ $new_loop_flag -eq 1 ]] ; then
            alarm_everyday $ALARM_TIME
            if [[ $? -eq 1  ]] ; then
                myprint "Alarm OK. Start daliybuild ..."
                daliybuild_run
                if [[ $? -eq 0 ]] ; then
                    myprint "my build pass"
                    new_loop_flag=0
                else
                    myprint "My build fail"
                    myprint "Try again"
                fi
            fi
        fi

        myprint "-r" "Waiting for alarm"
        sleep 1

    done
}

main

