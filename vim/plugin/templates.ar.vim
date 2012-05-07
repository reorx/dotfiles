" This is a self-extracting vimscript archive.
"
" To extract it, source the file from within vim.
"
" vimscript archive is copyright Aristotle Pagaltzis <pagaltzis@gmx.de>
" It is free software; you can redistribute it and/or modify it under the
" terms of either the Artistic License or the GNU General Public License.

set lazyredraw

function s:modlen( filename, modifier )
	return strlen( fnamemodify( a:filename, a:modifier ) )
endfunction

let vr = $VIMRUNTIME
let pathsep = strpart( vr, s:modlen( vr, ':h' ), strlen( vr ) - s:modlen( vr, ':h' ) - s:modlen( vr, ':t' ) )
unlet vr

delfunction s:modlen

let rtps = globpath( &runtimepath, pathsep )
while strlen( rtps )
	let userdir = matchstr( rtps, "^[^\n]*" )
	if filewritable( userdir ) == 2 | break | endif
	unlet userdir
	let rtps = substitute( rtps, "^[^\n]*\\n\\?", '', 'e' )
endwhile
unlet rtps

if ! exists( 'userdir' )
	echoerr 'Sorry, there are no writable paths in your &runtimepath.'
	finish
endif

new
silent execute '0read' expand( '<sfile>:p' )
silent $ delete _

let endline = line( '$' )


unlet endline

unlet pathsep
unlet userdir

silent quit!

set nolazyredraw

"file: plugin/templates.vim
"=" Vim global plugin for providing templates for new files
"=" Maintainer:  Aristotle Pagaltzis <pagaltzis@gmx.de>
"=" Last Change: 2004-12-28
"=" License:     This script is free software; you can redistribute it and/or
"="              modify it under the terms of either the Artistic License or
"="              the GNU General Public License.
"=
"=if exists( 'g:loaded_template' ) | finish | endif
"=let g:loaded_template = 1
"=
"=augroup template
"=	autocmd!
"=	autocmd FileType * if line2byte( line( '$' ) + 1 ) == -1 | call s:loadtemplate( &filetype ) | endif
"=augroup END
"=
"=function! s:globpathlist( path, ... )
"=	let i = 1
"=	let result = a:path
"=	while i <= a:0
"=		let result = substitute( escape( globpath( result, a:{i} ), ' ,\' ), "\n", ',', 'g' )
"=		if strlen( result ) == 0 | return '' | endif
"=		let i = i + 1
"=	endwhile
"=	return result
"=endfunction
"=
"=function! s:loadtemplate( filetype )
"=	let templatefile = matchstr( s:globpathlist( &runtimepath, 'templates', a:filetype ), '\(\\.\|[^,]\)*', 0 )
"=	if strlen( templatefile ) == 0 | return | endif
"=	silent execute 1 'read' templatefile
"=	1 delete _
"=	if search( 'cursor:', 'W' )
"=		let cursorline = strpart( getline( '.' ), col( '.' ) - 1 )
"=		let y = matchstr( cursorline, '^cursor:\s*\zs\d\+\ze' )
"=		let x = matchstr( cursorline, '^cursor:\s*\d\+\s\+\zs\d\+\ze' )
"=		let d = matchstr( cursorline, '^cursor:\s*\d\+\s\+\(\d\+\s\+\)\?\zsdel\>\ze' )
"=		if ! strlen( x ) | let x = 0 | endif
"=		if ! strlen( y ) | let y = 0 | endif
"=		if d == 'del' | delete _ | endif
"=		call cursor( y, x )
"=	endif
"=	set nomodified
"=endfunction
"
"=command -nargs=1 New new | set ft=<args>
"file: templates/html
"=<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
"=<html xmlns="http://www.w3.org/1999/xhtml">
"=<head>
"=<title>FIXME</title>
"=<!--
"=<link rel="stylesheet" type="text/css" href="FIXME" />
"=<script type="text/javascript" src="FIXME"></script>
"=<style type="text/css">
"=/* <![CDATA[ */
"=/* ]]> */
"=</style>
"=-->
"=</head>
"=<body>
"=
"=</body>
"=</html>
"=# cursor: 15 del
"file: templates/perl
"=#!/usr/bin/perl
"=use strict;
"=use warnings;
"=
"=
"=# cursor: 5 del
"file: templates/sh
"=#!/bin/bash
"=
"=# cursor: 2 del
