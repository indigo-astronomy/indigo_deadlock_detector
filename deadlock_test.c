// Copyright (C) 2020 Rumen G. Bogdanovski
// All rights reserved.
//
// You can use this software under the terms of MIT license (see LICENSE).

#include <stdio.h>
#include <pthread.h>
#include <stdlib.h>
#include <unistd.h>

pthread_mutex_t mutex1 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex2 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex3 = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t mutex4 = PTHREAD_MUTEX_INITIALIZER;

void *lock_thread_func1(void *temp) {
	pthread_mutex_lock(&mutex1);
	sleep(1);
	pthread_mutex_lock(&mutex2);
	/* ..... */
	pthread_mutex_unlock(&mutex2);
	pthread_mutex_unlock(&mutex1);
	return NULL;
}


void *lock_thread_func2(void *temp) {
	pthread_mutex_lock(&mutex2);
	sleep(1);
	pthread_mutex_lock(&mutex1);
	/* ..... */
  	pthread_mutex_unlock(&mutex1);
  	pthread_mutex_unlock(&mutex2);
  	return NULL;
}


void *lock_thread_func3(void *temp) {
        pthread_mutex_lock(&mutex3);
        sleep(1);
        pthread_mutex_lock(&mutex3);
        /* ..... */
        pthread_mutex_unlock(&mutex3);
        pthread_mutex_unlock(&mutex3);
        return NULL;
}


void *lock_thread_func4(void *temp) {
        pthread_mutex_lock(&mutex4);
        /* ..... */
        pthread_mutex_unlock(&mutex4);
        return NULL;
}


int main() {
  pthread_t thread1, thread2, thread3, thread4;
  pthread_attr_t attr;
  void *res;
  pthread_mutex_lock(&mutex4);
  pthread_create(&thread1, NULL, &lock_thread_func1, NULL);
  pthread_create(&thread2, NULL, &lock_thread_func2, NULL);
  pthread_create(&thread3, NULL, &lock_thread_func3, NULL);
  pthread_create(&thread4, NULL, &lock_thread_func4, NULL);
  printf("Inter-locked threads ctreated!\n");
  pthread_join(thread1,&res);
  pthread_join(thread2,&res);
  pthread_join(thread3,&res);
  pthread_mutex_unlock(&mutex4);
}
