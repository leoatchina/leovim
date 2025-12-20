
" shipped from retorillo/md5.vim to reduce dependency

let s:WORD_MAX = 0xffffffff
let s:BITS =
  \ [ 0x80000000, 0x40000000, 0x20000000, 0x10000000,
  \   0x08000000, 0x04000000, 0x02000000, 0x01000000,
  \   0x00800000, 0x00400000, 0x00200000, 0x00100000,
  \   0x00080000, 0x00040000, 0x00020000, 0x00010000,
  \   0x00008000, 0x00004000, 0x00002000, 0x00001000,
  \   0x00000800, 0x00000400, 0x00000200, 0x00000100,
  \   0x00000080, 0x00000040, 0x00000020, 0x00000010,
  \   0x00000008, 0x00000004, 0x00000002, 0x00000001, ]
let s:LSHIFTER =
  \ [ 0x7fffffff, 0x3fffffff, 0x1fffffff, 0x0fffffff,
  \   0x07ffffff, 0x03ffffff, 0x01ffffff, 0x00ffffff,
  \   0x007fffff, 0x003fffff, 0x001fffff, 0x000fffff,
  \   0x0007ffff, 0x0003ffff, 0x0001ffff, 0x0000ffff,
  \   0x00007fff, 0x00003fff, 0x00001fff, 0x00000fff,
  \   0x000007ff, 0x000003ff, 0x000001ff, 0x000000ff,
  \   0x0000007f, 0x0000003f, 0x0000001f, 0x0000000f,
  \   0x00000007, 0x00000003, 0x00000001, 0x00000000, ]
let s:RSHIFTER =
  \ [ 0x7fffffff, 0x7ffffffe, 0x7ffffffc, 0x7ffffff8,
  \   0x7ffffff0, 0x7fffffe0, 0x7fffffc0, 0x7fffff80,
  \   0x7fffff00, 0x7ffffe00, 0x7ffffc00, 0x7ffff800,
  \   0x7ffff000, 0x7fffe000, 0x7fffc000, 0x7fff8000,
  \   0x7fff0000, 0x7ffe0000, 0x7ffc0000, 0x7ff80000,
  \   0x7ff00000, 0x7fe00000, 0x7fc00000, 0x7f800000,
  \   0x7f000000, 0x7e000000, 0x7c000000, 0x78000000,
  \   0x70000000, 0x60000000, 0x40000000, 0x00000000, ]
let s:K =
  \ [ 0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee,
  \   0xf57c0faf, 0x4787c62a, 0xa8304613, 0xfd469501,
  \   0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
  \   0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
  \   0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa,
  \   0xd62f105d, 0x02441453, 0xd8a1e681, 0xe7d3fbc8,
  \   0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
  \   0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
  \   0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c,
  \   0xa4beea44, 0x4bdecfa9, 0xf6bb4b60, 0xbebfbc70,
  \   0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
  \   0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
  \   0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039,
  \   0x655b59c3, 0x8f0ccc92, 0xffeff47d, 0x85845dd1,
  \   0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
  \   0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391 ]
let s:s =
  \ [  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,  7, 12, 17, 22,
  \    5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,  5,  9, 14, 20,
  \    4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,  4, 11, 16, 23,
  \    6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21,  6, 10, 15, 21, ]
let s:loop64 =
  \ [  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15,
  \   16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31,
  \   32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47,
  \   48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, ]

function! s:bitshift(word, amount)
  let a = abs(a:amount)
  if a >= 32 || a:word == 0
    return 0
  elseif a:amount == 0
    return a:word
  elseif a:amount < 0
    if a == 31
      return and(a:word, s:BITS[0]) ? 1 : 0
    else
      let v = and(a:word, s:RSHIFTER[a]) / s:BITS[31-a]
      return and(a:word, s:BITS[0]) ? or(v, s:BITS[a]) : v
    endif
  else
    if a == 31
      return and(a:word, s:BITS[31]) ? s:BITS[0] : 0
    else
      let v = and(a:word, s:LSHIFTER[a]) * s:BITS[31-a]
      return and(a:word, s:BITS[a]) ? or(v, s:BITS[0]) : v
    endif
  endif
endfunction
function! s:rotateleft(word, amount)
  if a:amount == 0
    return a:word
  endif
  let v = 0
  let c = 0
  let a = abs(a:amount) % 32
  while c < 32
    let bit = and(s:BITS[c], a:word)
    if bit
      if c < a
        let v = or(s:BITS[c + (32 - a)], v)
      else
        let v = or(s:BITS[c - a], v)
      endif
    endif
    let c = c + 1
  endwhile
  return v
endfunction
if has('num64')
  function! s:wordadd(x, ...)
    let word = a:x
    for l in a:000
      let word = (word + l) % (s:WORD_MAX + 1)
      if word < 0
        let word = s:WORD_MAX + (word + 1)
      endif
    endfor
    return word
  endfunction
else
  function! s:wordadd(x, ...)
    let high = s:bitshift(a:x, -16)
    let low = and(a:x, 0xffff)
    for y in a:000
      let high = high + s:bitshift(y, -16)
      let low = low + and(y, 0xffff)
      if low > 0xffff
        let high = high + 1
        let low = low - (0xffff + 1)
      endif
      if high > 0xffff
        let high = high - (0xffff + 1)
      endif
    endfor
    return or(s:bitshift(high, 16), low)
  endfunction
endif
function! s:long2bytes(long)
  let hword = s:word2bytes(and(s:bitshift(a:long, -32), s:WORD_MAX))
  let lword = s:word2bytes(and(s:bitshift(a:long, -0 ), s:WORD_MAX))
  return extend(lword, hword)
endfunction
function! s:word2bytes(word)
  let b1 = and(s:bitshift(a:word, -24), 0xff)
  let b2 = and(s:bitshift(a:word, -16), 0xff)
  let b3 = and(s:bitshift(a:word, -8 ), 0xff)
  let b4 = and(s:bitshift(a:word, -0 ), 0xff)
  return [b4, b3, b2, b1]
endfunction
function! s:str2bytes(str)
  let c = 0
  let bytes = []
  let len = strlen(a:str)
  while c < len
    call add(bytes, char2nr(a:str[c]))
    let c += 1
  endwhile
  return bytes
endfunction
function! s:word2hex(word)
  let b1 = and(s:bitshift(a:word, -24), 0xff)
  let b2 = and(s:bitshift(a:word, -16), 0xff)
  let b3 = and(s:bitshift(a:word, -8 ), 0xff)
  let b4 = and(s:bitshift(a:word, 0  ), 0xff)
  return printf("%02x%02x%02x%02x", b4, b3, b2, b1)
endfunction
function! s:bytes2word(bytes, offset)
  return s:bitshift(a:bytes[a:offset+3], 24)
    \  + s:bitshift(a:bytes[a:offset+2], 16)
    \  + s:bitshift(a:bytes[a:offset+1], 8)
    \  + a:bytes[a:offset+0]
endfunction
function! s:str2word(str, offset)
  return s:bitshift(char2nr(a:str[a:offset+3]), 24)
    \  + s:bitshift(char2nr(a:str[a:offset+2]), 16)
    \  + s:bitshift(char2nr(a:str[a:offset+1]), 8)
    \  + char2nr(a:str[a:offset])
endfunction
function! s:md5_print(hash)
  return join([ s:word2hex(a:hash[0][0]),
              \ s:word2hex(a:hash[0][1]),
              \ s:word2hex(a:hash[0][2]),
              \ s:word2hex(a:hash[0][3]), ], '')
endfunction
function! s:md5_new()
  return [ [ 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476 ],
        \  [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        \    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        \    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        \    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, ] ]
endfunction
function! s:md5_padding(hash, tail, origbits)
  let bytes = s:str2bytes(a:tail)
  let bits = a:origbits
  call add(bytes, 0x80)
  let bits = bits + 8
  while bits % 512 != 448
    call add(bytes, 0)
    let bits += 8
  endwhile
  let c = 0
  let len = len(bytes)
  while c < len
    let bytes = extend(bytes, s:long2bytes(a:origbits))
    let M = a:hash[1]
    let M[ 0] = s:bytes2word(bytes, c+ 0)
    let M[ 1] = s:bytes2word(bytes, c+ 4)
    let M[ 2] = s:bytes2word(bytes, c+ 8)
    let M[ 3] = s:bytes2word(bytes, c+12)
    let M[ 4] = s:bytes2word(bytes, c+16)
    let M[ 5] = s:bytes2word(bytes, c+20)
    let M[ 6] = s:bytes2word(bytes, c+24)
    let M[ 7] = s:bytes2word(bytes, c+28)
    let M[ 8] = s:bytes2word(bytes, c+32)
    let M[ 9] = s:bytes2word(bytes, c+36)
    let M[10] = s:bytes2word(bytes, c+40)
    let M[11] = s:bytes2word(bytes, c+44)
    let M[12] = s:bytes2word(bytes, c+48)
    let M[13] = s:bytes2word(bytes, c+52)
    let M[14] = s:bytes2word(bytes, c+56)
    let M[15] = s:bytes2word(bytes, c+60)
    call s:md5_update(a:hash)
    let c += 64
  endwhile
endfunction
function! s:md5_append(hash, str, offset)
  let M = a:hash[1]
  let M[ 0] = s:str2word(a:str, a:offset   )
  let M[ 1] = s:str2word(a:str, a:offset+ 4)
  let M[ 2] = s:str2word(a:str, a:offset+ 8)
  let M[ 3] = s:str2word(a:str, a:offset+12)
  let M[ 4] = s:str2word(a:str, a:offset+16)
  let M[ 5] = s:str2word(a:str, a:offset+20)
  let M[ 6] = s:str2word(a:str, a:offset+24)
  let M[ 7] = s:str2word(a:str, a:offset+28)
  let M[ 8] = s:str2word(a:str, a:offset+32)
  let M[ 9] = s:str2word(a:str, a:offset+36)
  let M[10] = s:str2word(a:str, a:offset+40)
  let M[11] = s:str2word(a:str, a:offset+44)
  let M[12] = s:str2word(a:str, a:offset+48)
  let M[13] = s:str2word(a:str, a:offset+52)
  let M[14] = s:str2word(a:str, a:offset+56)
  let M[15] = s:str2word(a:str, a:offset+60)
  call s:md5_update(a:hash)
endfunction
function! s:md5_update(hash)
  let state = a:hash[0]
  let M = a:hash[1]
  let A = state[0]
  let B = state[1]
  let C = state[2]
  let D = state[3]
  for i in s:loop64
    if i <= 15
      let F = or(and(B, C), and(invert(B), D))
      let g = i
    elseif i <= 31
      let F = or(and(D, B), and(invert(D), C))
      let g = (5 * i + 1) % 16
    elseif i <= 47
      let F = xor(xor(B, C), D)
      let g = (3 * i + 5) % 16
    elseif i <= 63
      let F = xor(C, or(B, invert(D)))
      let g = (7 * i) % 16
    endif
    let d = D
    let D = C
    let C = B
    let b = s:rotateleft(s:wordadd(A, F, s:K[i], M[g]), s:s[i])
    let B = s:wordadd(B, b)
    let A = d
  endfor
  let state[0] = s:wordadd(state[0], A)
  let state[1] = s:wordadd(state[1], B)
  let state[2] = s:wordadd(state[2], C)
  let state[3] = s:wordadd(state[3], D)
endfunction

function! ZFBackup_MD5String(str)
  let hash = s:md5_new()
  let until = strlen(a:str) - 64
  let c = 0
  while c <= until
    call s:md5_append(hash, a:str, c)
    let c += 64
  endwhile
  call s:md5_padding(hash, a:str[c : ], strlen(a:str) * 8)
  return s:md5_print(hash)
endfunction
function! ZFBackup_MD5File(path)
   let str = join(readfile(a:path, 'b'), "\n")
   return ZFBackup_MD5String(str)
endfunction
