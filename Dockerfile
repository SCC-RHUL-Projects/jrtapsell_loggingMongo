FROM ubuntu
WORKDIR /build
ADD . /build
RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update && apt-get install -y python2.7 git gcc g++ python-pip python-dev clang-5.0
RUN pip install --upgrade pip
RUN pip install -r buildscripts/requirements.txt
RUN git status
RUN python2.7 buildscripts/scons.py -j $((2 * $(grep -c ^processor /proc/cpuinfo))) mongod
RUN strip --strip-all mongod


# Use an official Python runtime as a parent image
FROM ubuntu

RUN apt-get update
RUN apt-get install -y apt-transport-https
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.6.list
RUN apt-get update

RUN apt-get update && apt-get install -y nmap mongo-org-shell

# Set the working directory to /app
WORKDIR /app

COPY --from=0 /build/mongod ./
ADD static/* ./

RUN mkdir log
RUN mkdir data

RUN ./makeUser.sh

# Run app.py when the container launches
EXPOSE 27017
EXPOSE 24109
CMD ./mongod -f mongod.conf --auth | tee /proc/1/fd/1 | ncat -lkp 24109
