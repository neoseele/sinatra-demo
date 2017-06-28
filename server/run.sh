#!/bin/bash

sed -i "s/%APP_ADMIN_USER%/${APP_ADMIN_USER}/" /home/app/webapp/config/*
sed -i "s/%APP_ADMIN_PASSWORD%/${APP_ADMIN_PASSWORD}/" /home/app/webapp/config/*

/sbin/my_init
