//
//  ProtobufCodec.cpp
//  AsyncRPC-iOS
//
//  Created by Meng on 14/11/10.
//  Copyright (c) 2014年 nightfade. All rights reserved.
//

#include "ProtobufCodec.h"

#import <Foundation/Foundation.h>

#include <google/protobuf/descriptor.h>

#include <arpa/inet.h>  // htonl, ntohl
#include <stdint.h>

const int kHeaderLen = sizeof(int32_t);


static google::protobuf::Message* createMessage(const std::string& type_name)
{
    google::protobuf::Message* message = NULL;
    const google::protobuf::Descriptor* descriptor =
    google::protobuf::DescriptorPool::generated_pool()->FindMessageTypeByName(type_name);
    if (descriptor)
    {
        const google::protobuf::Message* prototype =
        google::protobuf::MessageFactory::generated_factory()->GetPrototype(descriptor);
        if (prototype)
        {
            message = prototype->New();
        }
    }
    return message;
}

int32_t ProtobufCodec::asInt32(const char* buf)
{
    int32_t be32 = 0;
    memcpy(&be32, buf, sizeof(be32));
    return ntohl(be32);
}


///
/// Encode protobuf Message to transport format defined above
/// returns a std::string.
///
/// returns a empty string if message.AppendToString() fails.
///
std::string ProtobufCodec::encode(const google::protobuf::Message& message)
{
    std::string result;
    
    result.resize(kHeaderLen);
    
    const std::string& typeName = message.GetTypeName();
    int32_t nameLen = static_cast<int32_t>(typeName.size());
    int32_t be32 = htonl(nameLen);
    result.append(reinterpret_cast<char*>(&be32), sizeof be32);
    result.append(typeName.c_str(), nameLen);
    bool succeed = message.AppendToString(&result);
    
    if (succeed)
    {
        int32_t len = htonl(result.size() - kHeaderLen);
        std::copy(reinterpret_cast<char*>(&len),
                  reinterpret_cast<char*>(&len) + sizeof len,
                  result.begin());
    }
    else
    {
        result.clear();
    }
    
    return result;
}

///
/// Decode protobuf Message from transport format defined above.
/// returns a Message*
///
/// returns NULL if fails.
///
google::protobuf::Message* ProtobufCodec::decode(const std::string& buf)
{
    google::protobuf::Message* result = NULL;
    
    int32_t len = static_cast<int32_t>(buf.size());
    int32_t nameLen = asInt32(buf.c_str());
    std::string typeName(buf.begin() + kHeaderLen, buf.begin() + kHeaderLen + nameLen);
    google::protobuf::Message* message = createMessage(typeName);
    if (message)
    {
        const char* data = buf.c_str() + kHeaderLen + nameLen;
        int32_t dataLen = len - nameLen - kHeaderLen;
        if (message->ParseFromArray(data, dataLen))
        {
            result = message;
        }
        else
        {
            NSLog(@"Parse Protobuf Message Error!");
            delete message;
        }
    }
    else
    {
        NSLog(@"Unknown Protobuf Message Type!");
    }
    
    return result;
}