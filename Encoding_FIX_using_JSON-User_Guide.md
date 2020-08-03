Introduction
============

Objective
---------

The objective of this user guide is to support development of web applications
that require FIX semantics. JSON is another alternative to existing FIX
encodings, including tagvalue, FIXML, FAST, SBE and Google Protocol Buffers.

JSON encoding of FIX is optimized for operations in a web browser without the
need for other software distribution to clients.

JSON encoding is also optimized for conversion to and from other FIX encodings.
It is therefore a goal of this encoding not to discard any information that
would be useful during such conversions.

It is not a goal to specify a particular template or schema format here,
however it is a goal not to preclude the use of one.

On the scale of human-to-server web interactions, JSON provides acceptable
performance. However, is not a goal to optimize JSON encoding to execute at
very low latency like FIX binary encodings.

JavaScript and JSON
-------------------

JavaScript is the predominant language for developing client-side logic in web
applications. JavaScript is supported by all popular web browsers. A built-in
feature of the language is JavaScript Object Notation (JSON). JSON syntax is
identical to the code for creating JavaScript objects. It minimizes development
effort while avoiding the complexity and greed for resources of XML parsers and
the like.

An important characteristic of JSON is that it is self-describing. Elements
have readable symbolic names. Therefore, message handlers can process message
elements without looking up metadata in a data dictionary or schema.

JSON wire format can readily be parsed and encoded in other programming
languages. There are several popular libraries for that purpose in Java, C\#,
C++, and so forth. These JSON implementations interoperate with JavaScript.

JSON Elements
-------------

JSON is so simple that the standard’s authors foresaw no need for versioning since it is never expected to change. To summarize:

- An **array** is an ordered list of values.
- An **object** is a collection of name/value pairs. Names are *strings*.
- A **value** can be an *object*, *array*, *number*, *string*, *boolean*, or *null*.
- **Numbers** are signed. There is no syntactic distinction between integer and floating point values. In practice, most implementations store all numbers as double precision binary floating point.
- **Strings** are Unicode, with a few rules for escaping special values.
- **Booleans** are *true* or *false*.
- Arbitrary levels of *object* nesting are allowed.

Standards References
--------------------

JavaScript is formalized as [Standard ECMA-262 ECMAScript® 2015 Language Specification](http://www.ecma-international.org/publications/standards/Ecma-262.htm).

JSON is standardized by [Standard ECMA-404 The JSON Data Interchange Format ](http://www.ecma-international.org/publications/standards/Ecma-404.htm).
The JSON standard is normative for this user guide.

Issues for Mapping JSON to FIX
------------------------------

This user guide provides standardized solutions to the following issues.

### Dates and Times

JSON has no explicit provision for encoding dates or times. However, most
languages/platforms that support JSON also support conversion of date/time to
and from strings in ISO 8601 format (e.g. the JavaScript **Date** object).

Another potential issue is that particular languages/platforms only support
millisecond precision (e.g. the JavaScript **Date** object), while FIX
timestamps may require microsecond or nanosecond precision. Given that any
timestamps captured on the client side are limited by PC clock precision,
millisecond precision should be sufficient for web applications.  When finer
than millisecond precision is required, applications should adhere to the
recommendations of [FIX.5.0 SP2 EP206: Clock Synchronization Data Types
Enhancements](https://www.fixtrading.org/packages/ep206/).

### Decimal Representation

JSON does not provide a numeric data type that is suitable for storing prices,
quantities, etc. Furthermore, since most implementations (including JavaScript)
store all JSON numeric values using a binary floating point data type, attempts
to represent decimals as scaled integers, as was done with FIX binary
encodings, are unfortunately pointless.

### Enumerations

Enumerations of valid values are needed for codes in FIX fields, but JSON has no special syntax for enumerations.

Languages/platforms that support JSON may also lack support for enumerations
(e.g. JavaScript).  Although it may be possible in such cases to emulate an
enumeration with an associative array of symbolic names and values,
deserialization of a code in JSON does not automatically associate to its
symbolic name, and serialized strings or numbers are not constrained to valid
values.

### No tags

JSON does not have a built-in feature equivalent to FIX field tags or component
IDs. This user guide suggests using symbolic names directly to avoid lookup by
tag. The reduction in processing is offset by longer messages on the wire. This
seems an acceptable trade-off since a web UI is unlikely to capture very large
numbers of fields per message.

### No Templates

JSON serialization and deserialization are not controlled by an external
template or schema, only by an object that is being serialized. Each object is
*sui generis*; JSON grew out of JavaScript, which does not have classes that
objects must conform to, as realized by Java, C\# and C++. It does have a
prototype feature, but JavaScript objects are quite malleable. Properties and
functions can be added on the fly. Nevertheless, it is possible to generate
JSON objects corresponding to messages defined by the FIX Repository or FIX
Orchestra.

Constraint
----------

This user guide will depend only on standard JavaScript features that are
implemented in most browsers and the JSON standard, without dependency on
third-party frameworks.

Field Encoding
==============

Data Types of Values
--------------------

This user guide specifies that all of the semantic data types of FIX protocol
should be mapped to JSON *string* values in order to maximize the ability of
applications to simply display the data.

Application logic must be tailored to handle data with proper semantics if it
does anything with the data other than simply display it. Since there is no
feature to convey the semantic type in-band, the actual FIX type must be
referenced at development time. It is recommended that applications use either
FIX Repository or FIX Orchestra for this purpose.

JSON does not provide a numeric data type that is suitable for storing prices,
quantities, etc. Furthermore, most implementations (e.g. JavaScript) store all
JSON numeric values using a binary floating point data type. Using JSON
*string* values to represent FIX protocol numeric types circumvents this issue,
and allows applications to choose the most appropriate data type provided by
their language/platform (e.g. the Java *BigDecimal* type).

Names
-----

Names of fields must be encoded exactly as they are spelled and capitalized in
the FIX Repository.

The field’s *Name* should be used instead of its *Tag* number to enable
applications to display a human-readable form with little or no logic and
without requiring a data dictionary in the browser. However, for user-defined
fields, the *Tag* number may be used instead of the *Name*.

The field’s *Value* should be used instead of its *SymbolicName* since there
are many cases (e.g. bonds, complex options) where the *SymbolicName* means
something other than how it is being used.

Field Encoding
--------------

Fields are encoded in accordance with the JSON standard as name/value pairs.
Values must be serialized as JSON *strings*.

Example of a FIX field encoded as a JSON name/value pair:

| FIX tag=value Encoding | JSON Encoding     |
|------------------------|-------------------|
| 31=47.50               | "LastPx": "47.50" |
| 54=1                   | "Side": "1"       |

### Byte order

Since all JSON values, including numbers, are serialized as their string
equivalent, there is no issue with byte order (endianness).

Message Structure
=================

Field Presence
--------------

Although JSON does have a special value for *null*, it need not be used for a
non-populated optional FIX field. Like FIX *tag=value* encoding, optional
fields that are not populated are simply not serialized on the wire.

Field Order
-----------

Like FIX *tag=value* encoding, order of fields within a message or repeating
group entry is not significant. All fields are accessed by name.

Message Framing
---------------

Each message is serialized as a JSON object, contained by opening and closing
braces. A message may contain other JSON objects, specifically, repeating
groups (see below).

Since this encoding is designed for use with web protocols, message framing is
generally handled by the session layer protocol, e.g. HTTP or websockets. In
these cases, no additional framing protocol is needed.

For cases where an additional framing protocol *is* needed, applications may use
*FIX Simple Open Framing Header* (SOFH).

Header, Body, and Trailer
-------------------------

Every JSON message must have top-level fields named “Header”, “Body”, and
“Trailer”:

```json
{
    "Header": {},
    "Body": {},
    "Trailer": {}
}
```

This structure serves the goal of *not* discarding information that is useful
when converting to/from other FIX encodings.

JSON encoding does not include a “CheckSum” field since it is unlikely to be
useful at best, and likely to be incorrect at worst (e.g. if copied over from
another FIX encoding).

Message Type
------------

To identify a message on the wire, every JSON message should have a “MsgType”
field in the “Header” sub-object. The value should be a valid *Value* of the
“MsgType” field as defined in the FIX repository:

Example for a “NewOrderSingle” message:

```json
{
    "Header": {
        "MsgType": "D"
    }
}
```

Repeating Groups
----------------

A repeating group is serialized as an array of JSON objects, each containing
the fields that belong to a particular repeating group entry. A JSON array is
surrounded by square brackets, and each entry is separated by a comma. Each
entry is its own JSON object. Because some of the fields may be optional, not
all entries are required to contain the same fields.

The count of entries is implicit to the array structure. There is no explicit
*NumInGroup* field in the JSON encoding.

The name of a repeating group is the name of the associated *NumInGroup* field
name as it appears in the FIX Repository.

Example of a “NoMDEntries” group with two entries:

```json
{
    "Header": {
        "MsgType": "W"
    },
    "Body": {
        "NoMDEntries": [
            { "MDEntryType": "0", "MDEntryPx": "2179.75", "MDEntrySize": "175" },
            { "MDEntryType": "1", "MDEntryPx": "2180.25", "MDEntrySize": "125" }
        ]
    }
}
```

### Empty group

An empty repeating group may be serialized in order to simplify conversion
to/from other FIX encodings.

### Nested groups

A JSON object for a repeating group entry may contain other objects to
represent nested repeating groups.

Sample Messages
===============

**MarketDataSnapshotFullRefresh**

```json
{
    "Header": {
        "BeginString": "FIXT.1.1",
        "MsgType": "W",
        "MsgSeqNum": "4567",
        "SenderCompID": "SENDER",
        "TargetCompID": "TARGET",
        "SendingTime": "20160802-21:14:38.717"
    },
    "Body": {
        "SecurityIDSource": "8",
        "SecurityID": "ESU6",
        "MDReqID": "789",
        "NoMDEntries": [
            { "MDEntryType": "0", "MDEntryPx": "1.50", "MDEntrySize": "75", "MDEntryTime": "21:14:38.688" },
            { "MDEntryType": "1", "MDEntryPx": "1.75", "MDEntrySize": "25", "MDEntryTime": "21:14:38.688" }
        ]
    },
    "Trailer": {
    }
}
```

Unsupported Features
====================

Metadata
--------

This user guide only specifies wire format. There is no provision for external
or internal metadata features.

Versioning
----------

Explicit versioning is not supported by the JSON encoding of FIX. Generally,
this is unnecessary since web sites serve client-side code all with page
contents. Since the server controls encoding on both sides, they should always
be internally consistent.
