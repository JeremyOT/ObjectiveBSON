//
//  BSON.m
//  BSON
//
//  Created by Jeremy Olmsted-Thompson on 12/29/11.
//  Copyright (c) 2011 JOT. All rights reserved.
//

#import "BSONSerialization.h"

#define BSON_DOUBLE 0x01
#define BSON_STRING 0x02
#define BSON_DOCUMENT 0x03
#define BSON_ARRAY 0x04
#define BSON_BINARY 0x05
#define BSON_UNDEFINED 0x06 //Deprecated
#define BSON_OBJECT_ID 0x07 //NA
#define BSON_BOOLEAN 0x08
#define BSON_UTC_TIMESTAMP_MS 0x09
#define BSON_NULL 0x0A
#define BSON_REGEX 0x0B //NA
#define BSON_DBPOINTER 0x0C //Deprecated
#define BSON_JAVASCRIPT 0x0D //NA
#define BSON_SYMBOL 0x0E //NA
#define BSON_CODE_W_S 0x0F //NA
#define BSON_INT_32 0x10
#define BSON_MONGO_TIMESTAMP 0x11 //NA
#define BSON_INT_64 0x12
#define BSON_MIN_KEY 0xFF //NA
#define BSON_MAX_KEY 0x7F //NA

@implementation ObjectID

+(ObjectID*)withID:(NSData*)id {
    ObjectID *obj = [[ObjectID alloc] init];
    obj.id = id;
    return obj;
}

-(BOOL)equals:(ObjectID*)other {
    return [self.id isEqualToData:other.id];
}

@end

@implementation BSONSerialization

#pragma mark - Serialization Functions

static void appendTypeAndName(NSMutableData *data, u_int8_t type, NSString *name) {
    [data appendBytes:&type length:1];
    const char *cstring = [name UTF8String];
    [data appendBytes:cstring length:strlen(cstring) + 1];
}

static void appendStringElement(NSMutableData *data, NSString *name, NSString *o) {
    appendTypeAndName(data, BSON_STRING, name);
    const char *cstring = [o UTF8String];
    int length = (int)strlen(cstring) + 1;
    [data appendBytes:&length length:4];
    [data appendBytes:cstring length:length];
}

static void appendNumberElement(NSMutableData *data, NSString *name, NSNumber *o) {
    switch (*[o objCType]) {
        case 'c': { //BOOL
            appendTypeAndName(data, BSON_BOOLEAN, name);
            BOOL value = [o boolValue];
            [data appendBytes:&value length:1];
            break;
        }
        case 'i': //int32
        case 'l': { //int32
            appendTypeAndName(data, BSON_INT_32, name);
            int value = [o intValue];
            [data appendBytes:&value length:4];
            break;
        }
        case 'q': { //int64
            appendTypeAndName(data, BSON_INT_64, name);
            int64_t value = [o longLongValue];
            [data appendBytes:&value length:8];
            break;
        }
        case 'f': //float
        case 'd': //double
        default: {
            appendTypeAndName(data, BSON_DOUBLE, name);
            double value = [o doubleValue];
            [data appendBytes:&value length:8];
            break;
        }
    }
}

static void appendDateElement(NSMutableData *data, NSString *name, NSDate *o) {
    appendTypeAndName(data, BSON_UTC_TIMESTAMP_MS, name);
    int64_t value = [o timeIntervalSince1970] * 1000.0;
    [data appendBytes:&value length:8]; 
}

static void appendObjectIDElement(NSMutableData *data, NSString *name, ObjectID *id) {
    appendTypeAndName(data, BSON_OBJECT_ID, name);
    [data appendData: id.id];
}

static void appendNullElement(NSMutableData *data, NSString *name) {
    appendTypeAndName(data, BSON_NULL, name);
}

static void appendDataElement(NSMutableData *data, NSString *name, NSData *o) {
    appendTypeAndName(data, BSON_BINARY, name);
    int length = (int)[o length];
    [data appendBytes:&length length:4];
    [data appendBytes:"\x00" length:1];
    [data appendData:o];
}

#pragma mark - Serialization Selectors

+(NSData*)BSONDataFromDictionary:(NSDictionary*)dictionary {
    NSMutableData *data = [NSMutableData dataWithBytes:(char[]){0,0,0,0} length:4];
    for (NSString *key in dictionary) {
        id object = [dictionary objectForKey:key];
        if ([object isKindOfClass:[NSString class]]) {
            appendStringElement(data, key, object);
        } else if ([object isKindOfClass:[NSNumber class]]) {
            appendNumberElement(data, key, object);
        } else if ([object isKindOfClass:[NSData class]]) {
            appendDataElement(data, key, object);
        } else if ([object isKindOfClass:[ObjectID class]]) {
            appendObjectIDElement(data, key, object);
        } else if ([object isKindOfClass:[NSDate class]]) {
            appendDateElement(data, key, object);
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            appendTypeAndName(data, BSON_DOCUMENT, key);
            [data appendData:[self BSONDataFromDictionary:object]];
        } else if ([object isKindOfClass:[NSArray class]]) {
            appendTypeAndName(data, BSON_ARRAY, key);
            [data appendData:[self BSONDataFromArray:object]];
        } else if ([object isKindOfClass:[NSNull class]]) {
            appendNullElement(data, key);
        } else {
            [NSException raise:@"Unsupported BSON Type" format:@"Cannot serialize class: %@", NSStringFromClass([object class])];
        }
    }
    [data appendBytes:"\x00" length:1];
    int length = (int)[data length];
    [data replaceBytesInRange:NSMakeRange(0, 4) withBytes:&length];
    return data;
}

+(NSData*)BSONDataFromArray:(NSArray*)array {
    int count = (int)[array count];
    NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[array count]];
    for (int i = 0; i < count; i++) {
        [keys addObject:[[NSNumber numberWithInt:i] stringValue]];
    }
    return [self BSONDataFromDictionary:[NSDictionary dictionaryWithObjects:array forKeys:keys]];
}

#pragma mark - Deserialization Functions

+(NSDictionary*)dictionaryFromBSONBytes:(char*)data {
    data += 4;
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    char type = 0;
    while ((type = *data)) {
        data ++;
        NSString *name = [NSString stringWithUTF8String:data];
        data += strlen(data) + 1;
        id value;
        switch (type) {
            case BSON_DOUBLE: {
                double rawVal;
                memcpy(&rawVal, data, sizeof(double));
                value = [NSNumber numberWithDouble:rawVal];
                data += sizeof(double);
                break;
            }
            case BSON_INT_32: {
                int rawVal;
                memcpy(&rawVal, data, sizeof(int));
                value = [NSNumber numberWithInt:rawVal];
                data += sizeof(int);
                break;
            }
            case BSON_INT_64: {
                int64_t rawVal;
                memcpy(&rawVal, data, sizeof(int64_t));
                value = [NSNumber numberWithLongLong:rawVal];
                data += sizeof(int64_t);
                break;
            }
            case BSON_OBJECT_ID: {
                value = [ObjectID withID:[NSData dataWithBytes:data length:12]];
                data += 12;
                break;
            }
            case BSON_BOOLEAN:
                value = [NSNumber numberWithBool:*((u_int8_t*)data)];
                data ++;
                break;
            case BSON_STRING: {
                int length = *((int*)data);
                data += 4;
                value = [NSString stringWithUTF8String:data];
                data += length;
                break;
            }
            case BSON_DOCUMENT: {
                int length;
                memcpy(&length, data, sizeof(int));
                value = [self dictionaryFromBSONBytes:data];
                data += length;
                break;
            }
            case BSON_ARRAY: {
                int length;
                memcpy(&length, data, sizeof(int));
                value = [self arrayFromBSONBytes:data];
                data += length;
                break;
            }
            case BSON_BINARY: {
                int length;
                memcpy(&length, data, sizeof(int));
                data += 5;
                value = [NSData dataWithBytes:data length:length];
                data += length;
                break;
            }
            case BSON_UTC_TIMESTAMP_MS:
                value = [NSDate dateWithTimeIntervalSince1970:(*((int64_t*)data))/1000.0];
                data += 8;
                break;
            case BSON_NULL:
                value = [NSNull null];
                break;
            default:
                [NSException raise:@"Unsupported BSON Type" format:@"Cannot deserialize element: %d", type];
                break;
        }
        [dictionary setObject:value forKey:name];
    }
    return dictionary;
}

+(NSDictionary *)dictionaryFromBSON:(NSData *)data {
    return [self dictionaryFromBSONBytes:(char*)[data bytes]];
}

+(NSArray*)arrayFromBSONBytes:(char*)data {
    NSDictionary *dictionary =[self dictionaryFromBSONBytes:data];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[dictionary count]];
    for (int i = 0; i < [dictionary count]; i++) {
        [array addObject:[NSNull null]];
    }
    for (NSString *key in dictionary) {
        [array replaceObjectAtIndex:[key intValue] withObject:[dictionary objectForKey:key]];
    }
    return array;
}

+(NSArray *)arrayFromBSON:(NSData *)data {
    return [self arrayFromBSONBytes:(char*)[data bytes]];
}

@end

@implementation NSDictionary (BSON)

-(NSData *)BSONRepresentation {
    return [BSONSerialization BSONDataFromDictionary:self];
}

+(NSDictionary *)dictionaryWithBSON:(NSData*)bsonData {
    return [BSONSerialization dictionaryFromBSON:bsonData];
}

@end

@implementation NSArray (BSON)

-(NSData *)BSONRepresentation {
    return [BSONSerialization BSONDataFromArray:self];
}

+(NSArray *)arrayWithBSON:(NSData*)bsonData {
    return [BSONSerialization arrayFromBSON:bsonData];
}

@end

@implementation NSData (BSON)

-(id)BSONValue {
    return [NSDictionary dictionaryWithBSON:self];
}

@end
