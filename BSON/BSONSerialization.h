//
//  BSON.h
//  BSON
//
//  Created by Jeremy Olmsted-Thompson on 12/29/11.
//  Copyright (c) 2011 JOT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObjectID : NSObject

@property NSData* id;

+(ObjectID*)withID:(NSData*)id;

-(BOOL)equals:(ObjectID*)other;

@end

@interface BSONSerialization : NSObject

+(NSData*)BSONDataFromDictionary:(NSDictionary*)dictionary;
+(NSData*)BSONDataFromArray:(NSArray*)array;

+(NSDictionary*)dictionaryFromBSONBytes:(char*)data;
+(NSArray*)arrayFromBSONBytes:(char*)data;

+(NSDictionary*)dictionaryFromBSON:(NSData*)data;
+(NSArray*)arrayFromBSON:(NSData*)data;

@end

@interface NSDictionary (BSON)

-(NSData*)BSONRepresentation;
+(NSDictionary *)dictionaryWithBSON:(NSData*)bsonData;

@end

@interface NSArray (BSON)

-(NSData*)BSONRepresentation;
+(NSArray*)arrayWithBSON:(NSData*)bsonData;

@end

@interface NSData (BSON)

-(id)BSONValue;

@end
