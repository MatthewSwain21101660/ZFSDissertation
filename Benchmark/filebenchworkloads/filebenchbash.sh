#! /bin/bash


echo "webserver"
rm -rf /zfstest/*
filebench -f webserver.f

echo "fileserver"
rm -rf /zfstest/*
filebench -f fileserver.f

echo "varmail"
rm -rf /zfstest/*
filebench -f varmail.f

echo "oltp"
rm -rf /zfstest/*
filebench -f oltp.f

echo "webproxy"
rm -rf /zfstest/*
filebench -f webproxy.f

echo "videoserver"
rm -rf /zfstest/*
filebench -f videoserver.f
