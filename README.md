ObjectiveBSON
=============
A small library that provides [BSON][bson] serialization methods for Mac or iOS applications.

Usage:
------
Copy BSONSerialization.h and BSONSerialization.m to your project.

Calling `[NSData BSONValue]` on an `NSData` object containing BSON data returns an
`NSDictionary` with the deserialized BSON data.

Calling `[NSDictionary BSONRepresentation]` returns an `NSData` with the serialized BSON
data.

Alternatively, `[NSDictionary dictionaryFromBSONBytes:(char*)]` may be used if you
only have access to a `char[]` containing the BSON data.

[bson]:http://bsonspec.org/
