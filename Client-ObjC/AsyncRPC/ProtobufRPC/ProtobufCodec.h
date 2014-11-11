//
//  ProtobufCodec.h
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/10.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#ifndef PROTOBUF_CODEC_H_
#define PROTOBUF_CODEC_H_

#include <string>
#include <google/protobuf/message.h>

// struct ProtobufTransportFormat __attribute__ ((__packed__))
// {
//   int32_t  len;
//   int32_t  nameLen;
//   char     typeName[nameLen];
//   char     protobufData[len-nameLen-8];
// }

class ProtobufCodec {
public:
    // output data with length header
    static std::string encode(const google::protobuf::Message& message);
    
    // input data without length header
    static google::protobuf::Message* decode(const std::string& buf);
    
    static int32_t asInt32(const char* buf);
};


#endif  // PROTOBUF_CODEC_H_