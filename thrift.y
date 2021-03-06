/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

/*
 * JISON port of Thrift Grammar
 * Based on thrifty.yy
 * http://svn.apache.org/viewvc/thrift/trunk/compiler/cpp/src/thrifty.yy?view=co
 */

/**
 * Thrift Grammar Implementation.
 *
 * For the most part this source file works its way top down from what you
 * might expect to find in a typical .thrift file, i.e. type definitions and
 * namespaces up top followed by service definitions using those types.
 */

%%

Program:
  HeaderList DefinitionList
    {
      yy.util.debug_log("Program -> Headers DefinitionList");
    }
    ;


/*  utility   */


CaptureDocText:
    {
      yy.util.debug_log("CaptureDocText");
      $$ = g_doctext;
      g_doctext = null;
    }
    ;

DestroyDocText:
    {
      yy.util.debug_log("DestroyDocText");
      g_doctext = null;
    }
    ;


/*  headers   */


HeaderList:
  HeaderList Header
    {
      yy.util.debug_log("HeaderList -> HeaderList Header");
    }
| DestroyDocText 
    {
      yy.util.debug_log("HeaderList -> ");
    }
  ;

Header:
  Include
    {
      yy.util.debug_log("Header -> Include");
    }
| tok_namespace tok_identifier tok_identifier
    {
      yy.util.debug_log("Header -> tok_namespace tok_identifier tok_identifier");
      yy.g_program.set_namespace($2, $3);
    }
| tok_namespace '*' tok_identifier
    {
      yy.util.debug_log("Header -> tok_namespace * tok_identifier");
      yy.g_program.set_namespace("*", $3);
    }
| tok_cpp_namespace tok_identifier
    {
      yy.util.debug_log("Header -> tok_cpp_namespace tok_identifier");
      yy.g_program.set_namespace("cpp", $2);
    }
| tok_cpp_include tok_literal
    {
      yy.util.debug_log("Header -> tok_cpp_include tok_literal");
      yy.g_program.add_cpp_include($2);
    }
| tok_php_namespace tok_identifier
    {
      yy.util.debug_log("Header -> tok_php_namespace tok_identifier");
      yy.g_program.set_namespace("php", $2);
    }
| tok_py_module tok_identifier
    {
      yy.util.debug_log("Header -> tok_py_module tok_identifier");
      yy.g_program.set_namespace("py", $2);
    }
| tok_perl_package tok_identifier
    {
      yy.util.debug_log("Header -> tok_perl_namespace tok_identifier");
      yy.g_program.set_namespace("perl", $2);
    }
| tok_ruby_namespace tok_identifier
    {
      yy.util.debug_log("Header -> tok_ruby_namespace tok_identifier");
      yy.g_program.set_namespace("rb", $2);
    }
| tok_smalltalk_category tok_st_identifier
    {
      yy.util.debug_log("Header -> tok_smalltalk_category tok_st_identifier");
      yy.g_program.set_namespace("smalltalk.category", $2);
    }
| tok_smalltalk_prefix tok_identifier
    {
      yy.util.debug_log("Header -> tok_smalltalk_prefix tok_identifier");
      yy.g_program.set_namespace("smalltalk.prefix", $2);
    }
| tok_java_package tok_identifier
    {
      yy.util.debug_log("Header -> tok_java_package tok_identifier");
      yy.g_program.set_namespace("java", $2);
    }
| tok_cocoa_prefix tok_identifier
    {
      yy.util.debug_log("Header -> tok_cocoa_prefix tok_identifier");
      yy.g_program.set_namespace("cocoa", $2);
    }
| tok_xsd_namespace tok_literal
    {
      yy.util.debug_log("Header -> tok_xsd_namespace tok_literal");
      yy.g_program.set_namespace("xsd", $2);
    }
| tok_csharp_namespace tok_identifier
    {
     yy.util.debug_log("Header -> tok_csharp_namespace tok_identifier");
     yy.g_program.set_namespace("csharp", $2);
    }
| tok_delphi_namespace tok_identifier
    {
     yy.util.debug_log("Header -> tok_delphi_namespace tok_identifier");
     yy.g_program.set_namespace("delphi", $2);
    }
  ;

Include:
  tok_include tok_literal
    {
      yy.util.debug_log("Include -> tok_include tok_literal");
      yy.g_program.add_include(null,$2);
    }
  ;


/*  definitions   */


DefinitionList:
  DefinitionList CaptureDocText Definition
    {
      yy.util.debug_log("DefinitionList -> DefinitionList Definition");
      if ($2 != null && $3 != null) {
        $3.set_doc($2);
      }

    }
|
    {
      yy.util.debug_log("DefinitionList -> ");
    }
  ;

Definition:
  Const
    {
      yy.util.debug_log("Definition -> Const");
      yy.g_program.add_const($1);
      $$ = 1;
    }
| TypeDefinition
    {
      yy.util.debug_log("Definition -> TypeDefinition");
      yy.g_scope.add_type($1.get_name(), $1);
      $$ = $1;
    }
| Service
    {
      yy.util.debug_log("Definition -> Service");
      yy.g_scope.add_service($1.get_name(), $1);
      yy.g_program.add_service($1);
      $$ = $1;
    }
  ;


/*  definition types   */

Const:
  tok_const FieldType tok_identifier '=' ConstValue CommaOrSemicolonOptional
    {
      yy.util.debug_log("Const -> tok_const FieldType tok_identifier = ConstValue");
      $$ = new yy.t_const($2, $3, $5);
    }
  ;

ConstValue:
  tok_int_constant
    {
      yy.util.debug_log("ConstValue -> tok_int_constant");
    }
| tok_dub_constant
    {
      yy.util.debug_log("ConstValue -> tok_dub_constant");
    }
| tok_literal
    {
      yy.util.debug_log("ConstValue -> tok_literal");
    }
| tok_identifier
    {
      yy.util.debug_log("ConstValue -> tok_identifier");
    }
| ConstList
    {
      yy.util.debug_log("ConstValue -> ConstList");
    }
| ConstMap
    {
      yy.util.debug_log("ConstValue -> ConstMap");
    }
  ;

ConstList:
  '[' ConstListContents ']'
    {
      yy.util.debug_log("ConstList -> [ ConstListContents ]");
      $$ = $2;
    }
  ;

ConstListContents:
  ConstListContents ConstValue CommaOrSemicolonOptional
    {
      yy.util.debug_log("ConstListContents -> ConstListContents ConstValue CommaOrSemicolonOptional");
      $$ = $1;
      $$.add_list($2);
    }
|
    {
      yy.util.debug_log("ConstListContents ->");
      $$ = new yy.t_const_value();
      $$.set_list();
    }
  ;

ConstMap:
  '{' ConstMapContents '}'
    {
      yy.util.debug_log("ConstMap -> { ConstMapContents }");
      $$ = $2;
    }
  ;

ConstMapContents:
  ConstMapContents ConstValue ':' ConstValue CommaOrSemicolonOptional
    {
      yy.util.debug_log("ConstMapContents -> ConstMapContents ConstValue CommaOrSemicolonOptional");
      $$ = $1;
      $$.add_map($2, $4);
    }
|
    {
      yy.util.debug_log("ConstMapContents ->");
      $$ = new yy.t_const_value();
      $$.set_map();
    }
  ;


TypeDefinition:
  Typedef
    {
      yy.util.debug_log("TypeDefinition -> Typedef");
      yy.g_program.add_typedef($1);
    }
| Enum
    {
      yy.util.debug_log("TypeDefinition -> Enum");
      yy.g_program.add_enum($1);
    }
| Senum
    {
      yy.util.debug_log("TypeDefinition -> Senum");
      yy.g_program.add_typedef($1);
    }
| Struct
    {
      yy.util.debug_log("TypeDefinition -> Struct");
      yy.g_program.add_struct($1);
    }
| Xception
    {
      yy.util.debug_log("TypeDefinition -> Xception");
      yy.g_program.add_xception($1);
    }
  ;

Typedef:
  tok_typedef FieldType tok_identifier
    {
      yy.util.debug_log("TypeDef -> tok_typedef FieldType tok_identifier");
      $$ = new yy.t_typedef(yy.g_program, $2, $3);
    }
  ;

Enum:
  tok_enum tok_identifier '{' EnumDefList '}'
    {
      yy.util.debug_log("Enum -> tok_enum tok_identifier { EnumDefList }");
      $$ = $4;
      $$.set_name($2);
      $$.resolve_values();
    }
  ;

EnumDefList:
  EnumDefList EnumDef
    {
      yy.util.debug_log("EnumDefList -> EnumDefList EnumDef");
      $$ = $1;
      $$.append($2);
    }
|
    {
      yy.util.debug_log("EnumDefList -> ");
      $$ = new yy.t_enum(yy.g_program);
    }
  ;

EnumDef:
  CaptureDocText tok_identifier '=' tok_int_constant CommaOrSemicolonOptional
    {
      yy.util.debug_log("EnumDef -> tok_identifier = tok_int_constant");
      $$ = new yy.t_enum_value($2, $4);
      if ($1 != null) {
        $$.set_doc($1);
      }
    }
|
  CaptureDocText tok_identifier CommaOrSemicolonOptional
    {
      yy.util.debug_log("EnumDef -> tok_identifier");
      $$ = new yy.t_enum_value($2);
      if ($1 != null) {
        $$.set_doc($1);
      }
    }
  ;

Senum:
  tok_senum tok_identifier '{' SenumDefList '}'
    {
      yy.util.debug_log("Senum -> tok_senum tok_identifier { SenumDefList }");
    }
  ;

SenumDefList:
  SenumDefList SenumDef
    {
      yy.util.debug_log("SenumDefList -> SenumDefList SenumDef");
      $$ = $1;
      $$.add_string_enum_val($2);
    }
|
    {
      yy.util.debug_log("SenumDefList -> ");
      $$ = new yy.t_base_type("string", t_base_type.t_base_name.TYPE_STRING);
      $$.set_string_enum(true);
    }
  ;

SenumDef:
  tok_literal CommaOrSemicolonOptional
    {
      yy.util.debug_log("SenumDef -> tok_literal");
      $$ = 1;
    }
  ;


StructHead:
  tok_struct
    {
      yy.util.debug_log("StructHead -> tok_struct");
    }
| tok_union
    {
      yy.util.debug_log("StructHead -> tok_union");
    }
  ;

Struct:
  StructHead tok_identifier XsdAll '{' FieldList '}' TypeAnnotations
    {
      yy.util.debug_log("Struct -> tok_struct tok_identifier { FieldList }");
      $$ = $5;
      $$.set_name($2);
    }
  ;
    
Xception:
  tok_xception tok_identifier '{' FieldList '}'
    {
      yy.util.debug_log("Xception -> tok_xception tok_identifier { FieldList }");
      $4.set_name($2);
      $4.set_xception(true);
      $$ = $4;
    }
  ;


Service:
  tok_service tok_identifier Extends '{' FunctionList '}'
    {
      yy.util.debug_log("Service -> tok_service tok_identifier { FunctionList }");
      $$ = $5;
      $$.set_name($2);
      $$.set_extends($3);
    }
  ;

Extends:
  tok_extends tok_identifier
    {
      yy.util.debug_log("Extends -> tok_extends tok_identifier");
    }
|
    {
    }
  ;

FunctionList:
  FunctionList Function
    {
      yy.util.debug_log("FunctionList -> FunctionList Function");
      $$ = $1;
      $1.add_function($2);
    }
|
    {
      yy.util.debug_log("FunctionList -> ");
      $$ = new yy.t_service(yy.g_program);
    }
  ;

Function:
  CaptureDocText Oneway FunctionType tok_identifier '(' FieldList ')' Throws CommaOrSemicolonOptional
    {
      yy.util.debug_log("Function -> FunctionType tok_identifier (FieldList) ");
      $6.set_name($4 + "_args");
      $$ = new yy.t_function($3, $4, $6, $8, $2);
      if ($1 != null) {
        $$.set_doc($1);
      }
    }
  ;

Oneway:
  tok_oneway
    {
      yy.util.debug_log("Oneway -> tok_oneway");
      $$ = true;
    }
|
    {
    }
  ;

Throws:
  tok_throws '(' FieldList ')'
    {
      yy.util.debug_log("Throws -> tok_throws ( FieldList )");
    }
|
    {
    }
  ;

FieldList:
  FieldList Field
    {
      yy.util.debug_log("FieldList -> FieldList Field");
      $$ = $1;
      $$.append($2);
    }
|
    {
      yy.util.debug_log("FieldList -> ");
      $$ = new yy.t_struct(yy.g_program);
    }
  ;

Field:
  CaptureDocText FieldIdentifier FieldRequiredness FieldType tok_identifier FieldValue XsdOptional XsdNillable XsdAttributes TypeAnnotations CommaOrSemicolonOptional
    {
      yy.util.debug_log("Field -> FieldIdentifier FieldRequiredness FieldType tok_identifier FieldValue XsdOptional XsdNillable XsdAttributes TypeAnnotations CommaOrSemicolonOptional");
      $$ = new yy.t_field($4, $5, $2);
      $$.set_req($3);
      if ($1 != null) {
        $$.set_doc($1);
      };
      if ($6 != null) {
        $$.set_value($6);
      };
    }
  ;

FieldIdentifier:
  tok_int_constant ':'
    {
      yy.util.debug_log("FieldIdentifier -> tok_int_constant");
    }
|
    {
      yy.util.debug_log("FieldIdentifier -> ");
    }
  ;

FieldRequiredness:
  tok_required
    {
      yy.util.debug_log("FieldRequiredness -> tok_required");
    }
| tok_optional
    {
      yy.util.debug_log("FieldRequiredness -> tok_optional");
    }
|
    {
    }
  ;

FieldValue:
  '=' ConstValue
    {
      $$ = $2;
    }
|
    {
    }
  ;

FunctionType:
  FieldType
    {
      yy.util.debug_log("FunctionType -> FieldType");
      $$ = $1;
    }
| tok_void
    {
      yy.util.debug_log("FunctionType -> tok_void");
    }
  ;

FieldType:
  tok_identifier
    {
      yy.util.debug_log("FieldType -> tok_identifier");
    }
| BaseType
    {
      yy.util.debug_log("FieldType -> BaseType");
      $$ = $1;
    }
| ContainerType
    {
      yy.util.debug_log("FieldType -> ContainerType");
      $$ = $1;
    }
  ;

BaseType:
  SimpleBaseType TypeAnnotations
    {
      yy.util.debug_log("BaseType -> SimpleBaseType TypeAnnotations");
      if ($2 !== null) {
          $$ = new yy.t_base_type($1);
      } else {
          $$ = $1;
      }
    }
  ;

SimpleBaseType:
  tok_string
    {
      yy.util.debug_log("BaseType -> tok_string");
    }
| tok_binary
    {
      yy.util.debug_log("BaseType -> tok_binary");
    }
| tok_slist
    {
      yy.util.debug_log("BaseType -> tok_slist");
    }
| tok_bool
    {
      yy.util.debug_log("BaseType -> tok_bool");
    }
| tok_byte
    {
      yy.util.debug_log("BaseType -> tok_byte");
    }
| tok_i16
    {
      yy.util.debug_log("BaseType -> tok_i16");
    }
| tok_i32
    {
      yy.util.debug_log("BaseType -> tok_i32");
    }
    }
| tok_i64
    {
      yy.util.debug_log("BaseType -> tok_i64");
    }
| tok_double
    {
      yy.util.debug_log("BaseType -> tok_double");
    }
  ;

ContainerType:
  SimpleContainerType TypeAnnotations
    {
      yy.util.debug_log("ContainerType -> SimpleContainerType TypeAnnotations");
      $$ = $1;
    }
  ;

SimpleContainerType:
  MapType
    {
      yy.util.debug_log("SimpleContainerType -> MapType");
      $$ = $1;
    }
| SetType
    {
      yy.util.debug_log("SimpleContainerType -> SetType");
      $$ = $1;
    }
| ListType
    {
      yy.util.debug_log("SimpleContainerType -> ListType");
      $$ = $1;
    }
  ;

MapType:
  tok_map CppType '<' FieldType ',' FieldType '>'
    {
      yy.util.debug_log("MapType -> tok_map <FieldType, FieldType>");
      $$ = new yy.t_map($4, $6);
    }
  ;

SetType:
  tok_set CppType '<' FieldType '>'
    {
      yy.util.debug_log("SetType -> tok_set<FieldType>");
      $$ = new yy.t_set($4);
    }
  ;

ListType:
  tok_list '<' FieldType '>' CppType
    {
      yy.util.debug_log("ListType -> tok_list<FieldType>");
      $$ = new yy.t_list($3);
    }
  ;

CppType:
  tok_cpp_type tok_literal
    {
      $$ = $2;
    }
|
    {
      $$ = null;
    }
  ;

TypeAnnotations:
  '(' TypeAnnotationList ')'
    {
      yy.util.debug_log("TypeAnnotations -> ( TypeAnnotationList )");
    }
|
    {
    }
  ;

TypeAnnotationList:
  TypeAnnotationList TypeAnnotation
    {
      yy.util.debug_log("TypeAnnotationList -> TypeAnnotationList , TypeAnnotation");
    }
|
    {
    }
  ;

TypeAnnotation:
  tok_identifier '=' tok_literal CommaOrSemicolonOptional
    {
      yy.util.debug_log("TypeAnnotation -> tok_identifier = tok_literal");
    }
  ;

/*  misc   */

CommaOrSemicolonOptional:
  ','
    {}
| ';'
    {}
|
    {}
  ;

XsdAll:
  tok_xsd_all
|
  { }
  ;

XsdOptional:
  tok_xsd_optional
|
  { }
  ;

XsdNillable:
  tok_xsd_nillable
|
  { }
  ;

XsdAttributes:
  tok_xsd_attrs '{' FieldList '}'
|
  { }
  ;

