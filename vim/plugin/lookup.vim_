" lookup.vim - :Lookup the word in a dictionary
" Author: Swaroop C H <swaroop@swaroopchNOSPAM.com>
" Version: 2
" Uses: Dict protocol (http://www.dict.org)
" Uses: dict://vocabulary.aioe.org server

if &cp || (exists("g:loaded_lookup") && g:loaded_lookup)
    finish
endif
let g:loaded_lookup = 1

function! s:isPythonInstalled()
    if !has('python')
        echoerr "lookup.vim requires vim compiled with +python"
    endif

    return has('python')
endfunction

function! s:DefPython()

    if !s:isPythonInstalled()
        return
    endif

python << PYTHONEOF

import vim
# http://gopher.quux.org:70/devel/dictclient/dictclient_1.0.1.tar.gz
# Download, 'tar -xvzf dictclient_1.0.1.tar.gz' and run 'python setup.py install'.
import dictclient

def safequotes(string):
    return string.replace('"', "'")

def lookup(word):
    output = ''

    # http://www.dict.org/links.html
    # http://www.luetzschena-stahmeln.de/dictd/index.php?freedictonly
    conn = dictclient.Connection('dict.org')

    output += "\n".join([d.getdefstr() for d in conn.define('wn', word)]) # WordNet
    output += "\n\n"
    output += "\n".join([d.getdefstr() for d in conn.define('moby-thes', word)])

    if len(output.strip()) == 0:
        output = "Sorry, couldn't find anything"

    vim.command('silent let g:lookup_meaning = "%s"' % safequotes(output))

PYTHONEOF
endfunction

call s:DefPython()

function! Lookup()

    if !s:isPythonInstalled()
        return
    endif

    let word = expand("<cword>")
    execute "python lookup('" . word . "')"
    echohl WarningMsg
    echo g:lookup_meaning
    echohl None

endfunction

command Lookup call Lookup()

