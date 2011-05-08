" Filename:      reporoot.vim
" Description:   Change directory to the nearest repository root directory
" Maintainer:    Jeremy Cantrell <jmcantrell@gmail.com>
" Last Modified: Sun 2011-05-08 01:47:38 (-0400)

if exists("g:reporoot_loaded")
    finish
endif

let g:reporoot_loaded = 1

let s:save_cpo = &cpo
set cpo&vim

function! s:Warn(message)
    echohl WarningMsg
    echo a:message
    echohl None
endfunction

function! s:RepoRoot(force, ...)
    let dirbak = a:0 == 0 ? getcwd() : a:1
    if a:force
        let dirbak = fnamemodify(dirbak, ':h')
    endif
    let dir = GetRepoRoot(dirbak)
    execute 'cd '.dir
endfunction

function! IsRepo(dir)
    for type in ['svn', 'git', 'hg', 'bzr']
        if isdirectory(a:dir.'/.'.type)
            return 1
        endif
    endfor
    return 0
endfunction

function! GetRepoRoot(dir)
    let dir = a:dir
    if filereadable(dir)
        let dir = fnamemodify(dir, ':h')
    endif
    if isdirectory(dir.'/.svn')
        while isdirectory(dir.'/.svn')
            let dir = fnamemodify(dir, ':h')
        endwhile
        return dir
    else
        let dirbak = dir
        while ! (dir == '/' || IsRepo(dir))
            let dir = fnamemodify(dir, ':h')
        endwhile
        if dir == '/'
            return dirbak
        else
            return dir
        endif
    endif
endfunction

command! -nargs=? -bang RepoRoot call s:RepoRoot(strlen('<bang>'), <f-args>)

let &cpo = s:save_cpo
