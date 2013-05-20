//
//  CBNetworkUtils.m
//  Seeds
//
//  Created by Patrick Deng on 13-5-18.
//  Copyright (c) 2013年 SimpleLife Studio. All rights reserved.
//

#import "CBNetworkUtils.h"

#include <netdb.h>
#include <arpa/inet.h>
#include <ifaddrs.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <arpa/inet.h>
#include <ifaddrs.h>

@implementation CBNetworkUtils

+ (NSString*)hostNameInWiFi
{
	struct ifaddrs *addrs;
	const struct ifaddrs *cursor;
	int error;
	error = getifaddrs(&addrs);
	NSString *hostname = nil;
	
	if (error)
	{
		DLog(@"Failed to obtain IP address with error: %d", error);
	}
	for (cursor = addrs; cursor; cursor = cursor->ifa_next)
	{
        if (cursor->ifa_addr->sa_family == AF_INET && (cursor->ifa_flags & IFF_LOOPBACK) == 0)
		{
            NSString *ifa_name = [NSString stringWithUTF8String:cursor->ifa_name];
			if([@"en0" isEqualToString:ifa_name] ||
               [@"en1" isEqualToString:ifa_name])
			{
				hostname = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)cursor->ifa_addr)->sin_addr)];
				DLog(@"hostname:%@",hostname);
				break;
			}
		}
	}
	freeifaddrs(addrs);
	return hostname;
}

@end
