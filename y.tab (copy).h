/* A Bison parser, made by GNU Bison 3.0.4.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_Y_TAB_H_INCLUDED
# define YY_YY_Y_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    TK_ID = 258,
    TK_CINT = 259,
    TK_CDOUBLE = 260,
    TK_VAR = 261,
    TK_PROGRAM = 262,
    TK_BEGIN = 263,
    TK_END = 264,
    TK_ATRIB = 265,
    TK_WRITELN = 266,
    TK_READ = 267,
    TK_CSTRING = 268,
    TK_FUNCTION = 269,
    TK_MOD = 270,
    TK_MAIG = 271,
    TK_MEIG = 272,
    TK_MENO = 273,
    TK_MAIO = 274,
    TK_DIF = 275,
    TK_EQUAL = 276,
    TK_IF = 277,
    TK_THEN = 278,
    TK_ELSE = 279,
    TK_AND = 280,
    TK_OR = 281,
    TK_NOT = 282,
    TK_FOR = 283,
    TK_TO = 284,
    TK_DO = 285,
    TK_ARRAY = 286,
    TK_OF = 287,
    TK_PTPT = 288,
    TK_WHILE = 289,
    TK_SWITCH = 290,
    TK_CASE = 291,
    TK_DEFAULT = 292
  };
#endif
/* Tokens.  */
#define TK_ID 258
#define TK_CINT 259
#define TK_CDOUBLE 260
#define TK_VAR 261
#define TK_PROGRAM 262
#define TK_BEGIN 263
#define TK_END 264
#define TK_ATRIB 265
#define TK_WRITELN 266
#define TK_READ 267
#define TK_CSTRING 268
#define TK_FUNCTION 269
#define TK_MOD 270
#define TK_MAIG 271
#define TK_MEIG 272
#define TK_MENO 273
#define TK_MAIO 274
#define TK_DIF 275
#define TK_EQUAL 276
#define TK_IF 277
#define TK_THEN 278
#define TK_ELSE 279
#define TK_AND 280
#define TK_OR 281
#define TK_NOT 282
#define TK_FOR 283
#define TK_TO 284
#define TK_DO 285
#define TK_ARRAY 286
#define TK_OF 287
#define TK_PTPT 288
#define TK_WHILE 289
#define TK_SWITCH 290
#define TK_CASE 291
#define TK_DEFAULT 292

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef int YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_Y_TAB_H_INCLUDED  */
