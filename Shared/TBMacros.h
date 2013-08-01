//
//  TBMacros.h
//  Tribo
//
//  Created by Carter Allen on 7/31/13.
//  Copyright (c) 2013 The Tribo Authors.
//  See the included License.md file.
//

//
// Weak-reference macros from MAZeroingWeakRef, which can be found at
// https://github.com/mikeash/MAZeroingWeakRef, while the code in question was
// taken from Remy Demarest's fork of the same project, found at
// https://github.com/PsychoH13/MAZeroingWeakRef.
// 
// The license of MAZeroingWeakRef is as follows:
//

//
// MAZeroingWeakRef and all code associated with it is distributed under a BSD
// license, as listed below.
//
//
// Copyright (c) 2010, Michael Ash
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of Michael Ash nor the names of its contributors may be used
// to endorse or promote products derived from this software without specific
// prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

#define MAWeakVar(var)            __weak_ ## var

#define MAWeakDeclare(var)        __weak id MAWeakVar(var) = var
#define MAWeakImport(var)         _Pragma("clang diagnostic push") _Pragma("clang diagnostic ignored \"-Wshadow\"") __typeof__(var) var = MAWeakVar(var) _Pragma("clang diagnostic pop")
#define MAWeakImportReturn(var)   MAWeakImport(var); do { if(var == nil) return; } while(NO)


#define MAWeakSelfDeclare()       MAWeakDeclare(self)
#define MAWeakSelfImport()        MAWeakImport(self)
#define MAWeakSelfImportReturn()  MAWeakImportReturn(self)
