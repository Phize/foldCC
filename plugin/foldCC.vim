" 折り畳み関数 {{{
function! FoldCCtext()
    " 表示するテキストの作成（折り畳みマーカーを除去）
    let line = s:rm_CmtAndFmr(v:foldstart)

    " 切り詰めサイズをウィンドウに合わせる {{{
    let regardMultibyte = strlen(line) - strdisplaywidth(line)

    let line_width = winwidth(0) - &foldcolumn
    if &number == 1 " 行番号表示オンのとき
        let line_width -= max([&numberwidth, len(line('$'))])
    endif

    if line_width > 77
        let line_width = 77
    endif
    let alignment = line_width - 11 + regardMultibyte
    " 11はprintf()で消費する分
    " issue:regardMultibyteで足される分が多い （61桁をオーバーして切り詰められてる場合
    " }}}

    return printf('%-' . alignment . '.' . alignment . 's [%2d][%4d]', line, v:foldlevel, v:foldend - v:foldstart + 1)
endfunction
" }}}

function! FoldCCnavi() " {{{
    if foldlevel('.')
        let save_csr = winsaveview()
        let parentList = []

        " カーソル行が折り畳まれているとき {{{
        let whtrClosed = foldclosed('.')
        if whtrClosed != -1
            call insert(parentList, s:surgery_line(whtrClosed))
            if foldlevel('.') == 1
                call winrestview(save_csr)
                return join(parentList, ' > ')
            endif

            normal! [z
            if foldclosed('.') == whtrClosed
                call winrestview(save_csr)
                return join(parentList, ' > ')
            endif
        endif
        " }}}

        " 折畳を再帰的に戻れるとき {{{
        while 1
            normal! [z
            call insert(parentList, s:surgery_line('.'))
            if foldlevel('.') == 1
                break
            endif
        endwhile
        call winrestview(save_csr)
        return join(parentList, ' > ')
        " }}}
    endif
endfunction " }}}

function! s:rm_CmtAndFmr(lnum) " {{{
    let line = getline(a:lnum)
    let comment = split(&commentstring, '%s')
    let comment_end =''
    if len(comment) > 1
        let comment_end = comment[1]
    endif
    let foldmarkers = split(&foldmarker, ',')

    return substitute(line, '\V\%(' . comment[0] . '\)\?\s\*' . foldmarkers[0] . '\%(\d\+\)\?\s\*\%(' . comment_end . '\)\?', '', '')
endfunction " }}}

function! s:surgery_line(lnum) " {{{
    let line = substitute(s:rm_CmtAndFmr(a:lnum), '\V\s', '', 'g')
    let regardMultibyte = len(line) - strdisplaywidth(line)
    let alignment = 60 + regardMultibyte
    return line[:alignment]
endfunction " }}}
