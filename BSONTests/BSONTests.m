//
//  BSONTests.m
//  BSONTests
//
//  Created by Jeremy Olmsted-Thompson on 12/29/11.
//  Copyright (c) 2011 JOT. All rights reserved.
//

#import "BSONTests.h"
#import "BSONSerialization.h"

@implementation BSONTests

-(void)setUp {
    [super setUp];
}

-(void)tearDown {
    [super tearDown];
}

-(void)testEmpty {
    NSDictionary *test = [NSDictionary dictionary];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"Empty dictionary serialization.");
}

-(void)testString {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:@"TestString", @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"One string dictionary serialization.");
}

-(void)testBOOL {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"True bool serialization.");
    test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"False bool serialization.");
}

-(void)testInt {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:235], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"Int serialization.");
    test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:0], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"0 int serialization.");
}

-(void)testLong {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:23005], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"Long serialization.");
    test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithLong:0], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"0 long serialization.");
}

-(void)testDouble {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:2323423423.2352355], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"Double serialization.");
    test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:0], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"0 double serialization.");
}

-(void)testFloat {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:23.23423f], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"Float serialization.");
    test = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.0f], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"0 float serialization.");
}

-(void)testDate {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSDate date], @"TestKey", nil];
    // Hack to counter for loss of precision
    STAssertTrue([[[[[test BSONRepresentation] BSONValue] objectForKey:@"TestKey"] description] isEqualToString:[[test objectForKey:@"TestKey"] description]], @"Date serialization.");
}

-(void)testDictionary {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithObject:@"Hello" forKey:@"HelloKey"], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"nested dictionary serialization.");
}

-(void)testArray {
    NSDictionary *test = [NSDictionary dictionaryWithObjectsAndKeys:[NSArray arrayWithObjects:@"obj1", @"obj2", nil], @"TestKey", nil];
    STAssertTrue([[[test BSONRepresentation] BSONValue] isEqualToDictionary:test], @"nested array serialization.");
}

@end
