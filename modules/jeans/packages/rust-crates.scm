;;; GNU Guix --- Functional package management for GNU
;;; Copyright © 2025 Hilton Chain <hako@ultrarare.space>
;;; Copyright © 2025 Gabriel Santos <gabrielsantosdesouza@disroot.org>
;;;
;;; This file is not part of GNU Guix.
;;;
;;; This file is free software; you can redistribute it and/or modify it
;;; under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 3 of the License, or (at
;;; your option) any later version.
;;;
;;; This file is distributed in the hope that it will be useful, but
;;; WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with this file.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Module featuring packages that usually constitute Rust library crates.
;; Basically, it's software that you shouldn't really
;; install in your system.

(define-module (jeans packages rust-crates)
  #:use-module (guix build-system cargo)
  #:export (lookup-cargo-inputs))

;;;
;;; This file is managed by 'guix import'.  Do NOT add definitions manually.
;;;

;;;
;;; Rust libraries fetched from crates.io and non-workspace development
;;; snapshots.
;;;

(define qqqq-separator 'begin-of-crates)

(define rust-aead-0.5.2
  (crate-source "aead" "0.5.2"
                "1c32aviraqag7926xcb9sybdm36v5vh9gnxpn4pxdwjc50zl28ni"))

(define rust-aes-0.7.5
  (crate-source "aes" "0.7.5"
                "1f0sdx2fsa8w3l7xzsyi9ry3shvnnsgc0znh50if9fm95vslg2wy"))

(define rust-aes-0.8.4
  (crate-source "aes" "0.8.4"
                "1853796anlwp4kqim0s6wm1srl4ib621nm0cl2h3c8klsjkgfsdi"))

(define rust-aes-gcm-0.10.3
  (crate-source "aes-gcm" "0.10.3"
                "1lgaqgg1gh9crg435509lqdhajg1m2vgma6f7fdj1qa2yyh10443"))

(define rust-android-system-properties-0.1.5
  (crate-source "android_system_properties" "0.1.5"
                "04b3wrz12837j7mdczqd95b732gw5q7q66cv4yn4646lvccp57l1"))

(define rust-anstyle-1.0.14
  (crate-source "anstyle" "1.0.14"
                "0030szmgj51fxkic1hpakxxgappxzwm6m154a3gfml83lq63l2wl"))

(define rust-anyhow-1.0.102
  (crate-source "anyhow" "1.0.102"
                "0b447dra1v12z474c6z4jmicdmc5yxz5bakympdnij44ckw2s83z"))

(define rust-async-broadcast-0.7.2
  (crate-source "async-broadcast" "0.7.2"
                "0ckmqcwyqwbl2cijk1y4r0vy60i89gqc86ijrxzz5f2m4yjqfnj3"))

(define rust-async-channel-2.5.0
  (crate-source "async-channel" "2.5.0"
                "1ljq24ig8lgs2555myrrjighycpx2mbjgrm3q7lpa6rdsmnxjklj"))

(define rust-async-executor-1.14.0
  (crate-source "async-executor" "1.14.0"
                "0al1rmxjy7p7r6h50z698q5lwssqs5a2vzmqbazm1z2sv1rgjsy9"))

(define rust-async-io-2.6.0
  (crate-source "async-io" "2.6.0"
                "1z16s18bm4jxlmp6rif38mvn55442yd3wjvdfhvx4hkgxf7qlss5"))

(define rust-async-lock-3.4.2
  (crate-source "async-lock" "3.4.2"
                "04c3xrrdrfrvh9v0ajxrangpy38qi76qq268zslphnxxjqjpy3r9"))

(define rust-async-process-2.5.0
  (crate-source "async-process" "2.5.0"
                "0xfswxmng6835hjlfhv7k0jrfp7czqxpfj6y2s5dsp05q0g94l7w"))

(define rust-async-recursion-1.1.1
  (crate-source "async-recursion" "1.1.1"
                "04ac4zh8qz2xjc79lmfi4jlqj5f92xjvfaqvbzwkizyqd4pl4hrv"))

(define rust-async-signal-0.2.13
  (crate-source "async-signal" "0.2.13"
                "0k66mpb3xp86hj4vxs7w40v7qz2jfbblrm9ddc5mglwwynxp1h23"))

(define rust-async-task-4.7.1
  (crate-source "async-task" "4.7.1"
                "1pp3avr4ri2nbh7s6y9ws0397nkx1zymmcr14sq761ljarh3axcb"))

(define rust-async-trait-0.1.89
  (crate-source "async-trait" "0.1.89"
                "1fsxxmz3rzx1prn1h3rs7kyjhkap60i7xvi0ldapkvbb14nssdch"))

(define rust-atomic-waker-1.1.2
  (crate-source "atomic-waker" "1.1.2"
                "1h5av1lw56m0jf0fd3bchxq8a30xv0b4wv8s4zkp4s0i7mfvs18m"))

(define rust-atty-0.2.14
  (crate-source "atty" "0.2.14"
                "1s7yslcs6a28c5vz7jwj63lkfgyx8mx99fdirlhi9lbhhzhrpcyr"))

(define rust-autocfg-1.5.0
  (crate-source "autocfg" "1.5.0"
                "1s77f98id9l4af4alklmzq46f21c980v13z2r1pcxx6bqgw0d1n0"))

(define rust-base64-0.22.1
  (crate-source "base64" "0.22.1"
                "1imqzgh7bxcikp5vx3shqvw9j09g9ly0xr0jma0q66i52r7jbcvj"))

(define rust-bitflags-1.3.2
  (crate-source "bitflags" "1.3.2"
                "12ki6w8gn1ldq7yz9y680llwk5gmrhrzszaa17g1sbrw2r2qvwxy"))

(define rust-bitflags-2.11.0
  (crate-source "bitflags" "2.11.0"
                "1bwjibwry5nfwsfm9kjg2dqx5n5nja9xymwbfl6svnn8jsz6ff44"))

(define rust-block-buffer-0.9.0
  (crate-source "block-buffer" "0.9.0"
                "1r4pf90s7d7lj1wdjhlnqa26vvbm6pnc33z138lxpnp9srpi2lj1"))

(define rust-block-buffer-0.10.4
  (crate-source "block-buffer" "0.10.4"
                "0w9sa2ypmrsqqvc20nhwr75wbb5cjr4kkyhpjm1z1lv2kdicfy1h"))

(define rust-block-modes-0.8.1
  (crate-source "block-modes" "0.8.1"
                "13id7rw1lhi83i701za8w5is3a8qkf4vfigqw3f8jp8mxldkvc1c"))

(define rust-block-padding-0.2.1
  (crate-source "block-padding" "0.2.1"
                "1bickjlmfw9iv63dp781n589rfybw879mik1va59833m1hvnqscd"))

(define rust-block2-0.6.2
  (crate-source "block2" "0.6.2"
                "1xcfllzx6c3jc554nmb5qy6xmlkl6l6j5ib4wd11800n0n3rvsyd"))

(define rust-blocking-1.6.2
  (crate-source "blocking" "1.6.2"
                "08bz3f9agqlp3102snkvsll6wc9ag7x5m1xy45ak2rv9pq18sgz8"))

(define rust-bumpalo-3.20.2
  (crate-source "bumpalo" "3.20.2"
                "1jrgxlff76k9glam0akhwpil2fr1w32gbjdf5hpipc7ld2c7h82x"))

(define rust-byteorder-1.5.0
  (crate-source "byteorder" "1.5.0"
                "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))

(define rust-cc-1.2.57
  (crate-source "cc" "1.2.57"
                "08q464b62d03zm7rgiixavkrh5lzfq18lwf884vgycj9735d23bs"))

(define rust-cfg-if-1.0.4
  (crate-source "cfg-if" "1.0.4"
                "008q28ajc546z5p2hcwdnckmg0hia7rnx52fni04bwqkzyrghc4k"))

(define rust-cfg-aliases-0.2.1
  (crate-source "cfg_aliases" "0.2.1"
                "092pxdc1dbgjb6qvh83gk56rkic2n2ybm4yvy76cgynmzi3zwfk1"))

(define rust-chrono-0.4.44
  (crate-source "chrono" "0.4.44"
                "1c64mk9a235271j5g3v4zrzqqmd43vp9vki7vqfllpqf5rd0fwy6"))

(define rust-cipher-0.3.0
  (crate-source "cipher" "0.3.0"
                "1dyzsv0c84rgz98d5glnhsz4320wl24x3bq511vnyf0mxir21rby"))

(define rust-cipher-0.4.4
  (crate-source "cipher" "0.4.4"
                "1b9x9agg67xq5nq879z66ni4l08m6m3hqcshk37d4is4ysd3ngvp"))

(define rust-clap-3.2.25
  (crate-source "clap" "3.2.25"
                "08vi402vfqmfj9f07c4gl6082qxgf4c9x98pbndcnwbgaszq38af"))

(define rust-clap-derive-3.2.25
  (crate-source "clap_derive" "3.2.25"
                "025hh66cyjk5xhhq8s1qw5wkxvrm8hnv5xwwksax7dy8pnw72qxf"))

(define rust-clap-lex-0.2.4
  (crate-source "clap_lex" "0.2.4"
                "1ib1a9v55ybnaws11l63az0jgz5xiy24jkdgsmyl7grcm3sz4l18"))

(define rust-concurrent-queue-2.5.0
  (crate-source "concurrent-queue" "2.5.0"
                "0wrr3mzq2ijdkxwndhf79k952cp4zkz35ray8hvsxl96xrx1k82c"))

(define rust-core-foundation-sys-0.8.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "core-foundation-sys" "0.8.7"
                "12w8j73lazxmr1z0h98hf3z623kl8ms7g07jch7n4p8f9nwlhdkp"))

(define rust-cpufeatures-0.2.17
  (crate-source "cpufeatures" "0.2.17"
                "10023dnnaghhdl70xcds12fsx2b966sxbxjq5sxs49mvxqw5ivar"))

(define rust-crossbeam-utils-0.8.21
  (crate-source "crossbeam-utils" "0.8.21"
                "0a3aa2bmc8q35fb67432w16wvi54sfmb69rk9h5bhd18vw0c99fh"))

(define rust-crypto-common-0.1.7
  (crate-source "crypto-common" "0.1.7"
                "02nn2rhfy7kvdkdjl457q2z0mklcvj9h662xrq6dzhfialh2kj3q"))

(define rust-crypto-mac-0.11.1
  (crate-source "crypto-mac" "0.11.1"
                "05672ncc54h66vph42s0a42ljl69bwnqjh0x4xgj2v1395psildi"))

(define rust-crypto-box-0.9.1
  (crate-source "crypto_box" "0.9.1"
                "02ghw0frbq99d9r52dmk3nxnac6s1i6cqm8ihnkchbm8757jn60n"))

(define rust-crypto-secretbox-0.1.1
  (crate-source "crypto_secretbox" "0.1.1"
                "1qa1w5s8dbyb88269zrmvbnillqahz394pl07bsds6gpmn3wzmmr"))

(define rust-ctr-0.9.2
  (crate-source "ctr" "0.9.2"
                "0d88b73waamgpfjdml78icxz45d95q7vi2aqa604b0visqdfws83"))

(define rust-curve25519-dalek-4.1.3
  (crate-source "curve25519-dalek" "4.1.3"
                "1gmjb9dsknrr8lypmhkyjd67p1arb8mbfamlwxm7vph38my8pywp"))

(define rust-curve25519-dalek-derive-0.1.1
  (crate-source "curve25519-dalek-derive" "0.1.1"
                "1cry71xxrr0mcy5my3fb502cwfxy6822k4pm19cwrilrg7hq4s7l"))

(define rust-deranged-0.5.8
  (crate-source "deranged" "0.5.8"
                "0711df3w16vx80k55ivkwzwswziinj4dz05xci3rvmn15g615n3w"))

(define rust-digest-0.9.0
  (crate-source "digest" "0.9.0"
                "0rmhvk33rgvd6ll71z8sng91a52rw14p0drjn1da0mqa138n1pfk"))

(define rust-digest-0.10.7
  (crate-source "digest" "0.10.7"
                "14p2n6ih29x81akj097lvz7wi9b6b9hvls0lwrv7b6xwyy0s5ncy"))

(define rust-directories-next-2.0.0
  (crate-source "directories-next" "2.0.0"
                "1g1vq8d8mv0vp0l317gh9y46ipqg2fxjnbc7lnjhwqbsv4qf37ik"))

(define rust-dirs-sys-next-0.1.2
  (crate-source "dirs-sys-next" "0.1.2"
                "0kavhavdxv4phzj4l0psvh55hszwnr0rcz8sxbvx20pyqi2a3gaf"))

(define rust-dispatch2-0.3.1
  (crate-source "dispatch2" "0.3.1"
                "0f5xmnbzpaz1g80m27kd804p75nswh0ikb6wvqh4ba3x9rz3c3hy"))

(define rust-downcast-0.11.0
  (crate-source "downcast" "0.11.0"
                "1wa78ahlc57wmqyq2ncr80l7plrkgz57xsg7kfzgpcnqac8gld8l"))

(define rust-endi-1.1.1
  (crate-source "endi" "1.1.1"
                "16a0076dx41vgrzzimm9clcym77h732czqjiajanmzvd1i1y5dv6"))

(define rust-enumflags2-0.7.12
  (crate-source "enumflags2" "0.7.12"
                "1vzcskg4dca2jiflsfx1p9yw1fvgzcakcs7cpip0agl51ilgf9qh"))

(define rust-enumflags2-derive-0.7.12
  (crate-source "enumflags2_derive" "0.7.12"
                "09rqffacafl1b83ir55hrah9gza0x7pzjn6lr6jm76fzix6qmiv7"))

(define rust-equivalent-1.0.2
  (crate-source "equivalent" "1.0.2"
                "03swzqznragy8n0x31lqc78g2af054jwivp7lkrbrc0khz74lyl7"))

(define rust-erased-serde-0.3.31
  (crate-source "erased-serde" "0.3.31"
                "0v5jyid1v8irf2n2875iwhm80cw8x75gfkdh7qvzxrymz5s8j4vc"))

(define rust-errno-0.3.14
  (crate-source "errno" "0.3.14"
                "1szgccmh8vgryqyadg8xd58mnwwicf39zmin3bsn63df2wbbgjir"))

(define rust-event-listener-5.4.1
  (crate-source "event-listener" "5.4.1"
                "1asnp3agbr8shcl001yd935m167ammyi8hnvl0q1ycajryn6cfz1"))

(define rust-event-listener-strategy-0.5.4
  (crate-source "event-listener-strategy" "0.5.4"
                "14rv18av8s7n8yixg38bxp5vg2qs394rl1w052by5npzmbgz7scb"))

(define rust-fastrand-2.3.0
  (crate-source "fastrand" "2.3.0"
                "1ghiahsw1jd68df895cy5h3gzwk30hndidn3b682zmshpgmrx41p"))

(define rust-fiat-crypto-0.2.9
  (crate-source "fiat-crypto" "0.2.9"
                "07c1vknddv3ak7w89n85ik0g34nzzpms6yb845vrjnv9m4csbpi8"))

(define rust-find-msvc-tools-0.1.9
  (crate-source "find-msvc-tools" "0.1.9"
                "10nmi0qdskq6l7zwxw5g56xny7hb624iki1c39d907qmfh3vrbjv"))

(define rust-foldhash-0.1.5
  (crate-source "foldhash" "0.1.5"
                "1wisr1xlc2bj7hk4rgkcjkz3j2x4dhd1h9lwk7mj8p71qpdgbi6r"))

(define rust-fragile-2.0.1
  (crate-source "fragile" "2.0.1"
                "06g69s9w3hmdnjp5b60ph15v367278mgxy1shijrllarc2pnrp98"))

(define rust-futures-core-0.3.32
  (crate-source "futures-core" "0.3.32"
                "07bbvwjbm5g2i330nyr1kcvjapkmdqzl4r6mqv75ivvjaa0m0d3y"))

(define rust-futures-io-0.3.32
  (crate-source "futures-io" "0.3.32"
                "063pf5m6vfmyxj74447x8kx9q8zj6m9daamj4hvf49yrg9fs7jyf"))

(define rust-futures-lite-2.6.1
  (crate-source "futures-lite" "2.6.1"
                "1ba4dg26sc168vf60b1a23dv1d8rcf3v3ykz2psb7q70kxh113pp"))

(define rust-generic-array-0.14.7
  (crate-source "generic-array" "0.14.7"
                "16lyyrzrljfq424c3n8kfwkqihlimmsg5nhshbbp48np3yjrqr45"))

(define rust-getrandom-0.2.17
  (crate-source "getrandom" "0.2.17"
                "1l2ac6jfj9xhpjjgmcx6s1x89bbnw9x6j9258yy6xjkzpq0bqapz"))

(define rust-getrandom-0.4.2
  (crate-source "getrandom" "0.4.2"
                "0mb5833hf9pvn9dhvxjgfg5dx0m77g8wavvjdpvpnkp9fil1xr8d"))

(define rust-ghash-0.5.1
  (crate-source "ghash" "0.5.1"
                "1wbg4vdgzwhkpkclz1g6bs4r5x984w5gnlsj4q5wnafb5hva9n7h"))

(define rust-hashbrown-0.12.3
  (crate-source "hashbrown" "0.12.3"
                "1268ka4750pyg2pbgsr43f0289l5zah4arir2k4igx5a8c6fg7la"))

(define rust-hashbrown-0.15.5
  (crate-source "hashbrown" "0.15.5"
                "189qaczmjxnikm9db748xyhiw04kpmhm9xj9k9hg0sgx7pjwyacj"))

(define rust-hashbrown-0.16.1
  (crate-source "hashbrown" "0.16.1"
                "004i3njw38ji3bzdp9z178ba9x3k0c1pgy8x69pj7yfppv4iq7c4"))

(define rust-heck-0.4.1
  (crate-source "heck" "0.4.1"
                "1a7mqsnycv5z4z5vnv1k34548jzmc0ajic7c1j8jsaspnhw5ql4m"))

(define rust-heck-0.5.0
  (crate-source "heck" "0.5.0"
                "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))

(define rust-hermit-abi-0.1.19
  (crate-source "hermit-abi" "0.1.19"
                "0cxcm8093nf5fyn114w8vxbrbcyvv91d4015rdnlgfll7cs6gd32"))

(define rust-hermit-abi-0.5.2
  (crate-source "hermit-abi" "0.5.2"
                "1744vaqkczpwncfy960j2hxrbjl1q01csm84jpd9dajbdr2yy3zw"))

(define rust-hex-0.4.3
  (crate-source "hex" "0.4.3"
                "0w1a4davm1lgzpamwnba907aysmlrnygbqmfis2mqjx5m552a93z"))

(define rust-hmac-0.11.0
  (crate-source "hmac" "0.11.0"
                "16z61aibdg4di40sqi4ks2s4rz6r29w4sx4gvblfph3yxch26aia"))

(define rust-hmac-0.12.1
  (crate-source "hmac" "0.12.1"
                "0pmbr069sfg76z7wsssfk5ddcqd9ncp79fyz6zcm6yn115yc6jbc"))

(define rust-iana-time-zone-0.1.65
  (crate-source "iana-time-zone" "0.1.65"
                "0w64khw5p8s4nzwcf36bwnsmqzf61vpwk9ca1920x82bk6nwj6z3"))

(define rust-iana-time-zone-haiku-0.1.2
  (crate-source "iana-time-zone-haiku" "0.1.2"
                "17r6jmj31chn7xs9698r122mapq85mfnv98bb4pg6spm0si2f67k"))

(define rust-id-arena-2.3.0
  (crate-source "id-arena" "2.3.0"
                "0m6rs0jcaj4mg33gkv98d71w3hridghp5c4yr928hplpkgbnfc1x"))

(define rust-indexmap-1.9.3
  (crate-source "indexmap" "1.9.3"
                "16dxmy7yvk51wvnih3a3im6fp5lmx0wx76i03n06wyak6cwhw1xx"))

(define rust-indexmap-2.13.0
  (crate-source "indexmap" "2.13.0"
                "05qh5c4h2hrnyypphxpwflk45syqbzvqsvvyxg43mp576w2ff53p"))

(define rust-inout-0.1.4
  (crate-source "inout" "0.1.4"
                "008xfl1jn9rxsq19phnhbimccf4p64880jmnpg59wqi07kk117w7"))

(define rust-is-terminal-0.4.17
  (crate-source "is-terminal" "0.4.17"
                "0ilfr9n31m0k6fsm3gvfrqaa62kbzkjqpwcd9mc46klfig1w2h1n"))

(define rust-itoa-1.0.18
  (crate-source "itoa" "1.0.18"
                "10jnd1vpfkb8kj38rlkn2a6k02afvj3qmw054dfpzagrpl6achlg"))

(define rust-js-sys-0.3.91
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.91"
                "171rzgq33wc1nxkgnvhlqqwwnrifs13mg3jjpjj5nf1z0yvib5xl"))

(define rust-leb128fmt-0.1.0
  (crate-source "leb128fmt" "0.1.0"
                "1chxm1484a0bly6anh6bd7a99sn355ymlagnwj3yajafnpldkv89"))

(define rust-libc-0.2.183
  (crate-source "libc" "0.2.183"
                "17c9gyia7rrzf9gsssvk3vq9ca2jp6rh32fsw6ciarpn5djlddmm"))

(define rust-libredox-0.1.14
  (crate-source "libredox" "0.1.14"
                "02p3pxlqf54znf1jhiyyjs0i4caf8ckrd5l8ygs4i6ba3nfy6i0p"))

(define rust-libusb1-sys-0.5.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libusb1-sys" "0.5.0"
                "0gq27za2av9gvdz1pgwlzaw3bflyhlxj0inlqp31cs5yig88jbp2"))

(define rust-linux-raw-sys-0.12.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.12.1"
                "0lwasljrqxjjfk9l2j8lyib1babh2qjlnhylqzl01nihw14nk9ij"))

(define rust-log-0.4.29
  (crate-source "log" "0.4.29"
                "15q8j9c8g5zpkcw0hnd6cf2z7fxqnvsjh3rw5mv5q10r83i34l2y"))

(define rust-mac-notification-sys-0.6.12
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "mac-notification-sys" "0.6.12"
                "1lq7zfxwhixs7npp05lhqvxjq4dj7v6wjcw1ijdq8iqsvn1ng899"))

(define rust-memchr-2.8.0
  (crate-source "memchr" "2.8.0"
                "0y9zzxcqxvdqg6wyag7vc3h0blhdn7hkq164bxyx2vph8zs5ijpq"))

(define rust-memoffset-0.9.1
  (crate-source "memoffset" "0.9.1"
                "12i17wh9a9plx869g7j4whf62xw68k5zd4k0k5nh6ys5mszid028"))

(define rust-mockall-0.14.0
  (crate-source "mockall" "0.14.0"
                "02v2gfdz5s927hqsz9qh6lchhiyh5wvyb6077nvcdyd5k109d3gm"))

(define rust-mockall-derive-0.14.0
  (crate-source "mockall_derive" "0.14.0"
                "1gvddfzazipxi8mcn0iqrljzqq2jxrwam1dki3hrnsnsdmqwwhfa"))

(define rust-named-pipe-0.4.1
  (crate-source "named_pipe" "0.4.1"
                "0azby10wzmsrf66m1bysbil0sjfybnvhsa8py093xz4irqy4975d"))

(define rust-nix-0.31.2
  (crate-source "nix" "0.31.2"
                "1lzmcqcnb9z8l4aq5ympx71bcwc0y5yf7d8jv6hnn7hc682hfvax"))

(define rust-notify-rust-4.12.0
  (crate-source "notify-rust" "4.12.0"
                "1hn6zpvl471gv0c9hkb870fa2lyscflg2jppc5carr8bnnhj1br1"))

(define rust-ntapi-0.4.3
  (crate-source "ntapi" "0.4.3"
                "1bl0d73avwla7laa4pkqvzvifjbs0avg65w01zxjydgx3likbcy3"))

(define rust-num-conv-0.2.0
  (crate-source "num-conv" "0.2.0"
                "0l4hj7lp8zbb9am4j3p7vlcv47y9bbazinvnxx9zjhiwkibyr5yg"))

(define rust-num-traits-0.2.19
  (crate-source "num-traits" "0.2.19"
                "0h984rhdkkqd4ny9cif7y2azl3xdfb7768hb9irhpsch4q3gq787"))

(define rust-num-enum-0.7.6
  (crate-source "num_enum" "0.7.6"
                "09kg0c2y08npdv0c9dbm4m9a9wz8w2qaiqqxl4gj3v22hj1wl2sx"))

(define rust-num-enum-derive-0.7.6
  (crate-source "num_enum_derive" "0.7.6"
                "1y0x9z49s27vdas6mglqbv02sgkdmbr8ns2kwspzrp2ra81rh2b8"))

(define rust-objc2-0.6.4
  (crate-source "objc2" "0.6.4"
                "17x8qpl512frscfqbmgjr20kg3y4r0xdqxphja17dz5f0znsh4is"))

(define rust-objc2-core-foundation-0.3.2
  (crate-source "objc2-core-foundation" "0.3.2"
                "0dnmg7606n4zifyjw4ff554xvjmi256cs8fpgpdmr91gckc0s61a"))

(define rust-objc2-encode-4.1.0
  (crate-source "objc2-encode" "4.1.0"
                "0cqckp4cpf68mxyc2zgnazj8klv0z395nsgbafa61cjgsyyan9gg"))

(define rust-objc2-foundation-0.3.2
  (crate-source "objc2-foundation" "0.3.2"
                "0wijkxzzvw2xkzssds3fj8279cbykz2rz9agxf6qh7y2agpsvq73"))

(define rust-objc2-io-kit-0.3.2
  (crate-source "objc2-io-kit" "0.3.2"
                "05dvfcf97w39daaj5qsbfc399lw9hbx3s4h9nwgxrmlpjnizpyik"))

(define rust-once-cell-1.21.4
  (crate-source "once_cell" "1.21.4"
                "0l1v676wf71kjg2khch4dphwh1jp3291ffiymr2mvy1kxd5kwz4z"))

(define rust-opaque-debug-0.3.1
  (crate-source "opaque-debug" "0.3.1"
                "10b3w0kydz5jf1ydyli5nv10gdfp97xh79bgz327d273bs46b3f0"))

(define rust-ordered-stream-0.2.0
  (crate-source "ordered-stream" "0.2.0"
                "0l0xxp697q7wiix1gnfn66xsss7fdhfivl2k7bvpjs4i3lgb18ls"))

(define rust-os-str-bytes-6.6.1
  (crate-source "os_str_bytes" "6.6.1"
                "1885z1x4sm86v5p41ggrl49m58rbzzhd1kj72x46yy53p62msdg2"))

(define rust-parking-2.2.1
  (crate-source "parking" "2.2.1"
                "1fnfgmzkfpjd69v4j9x737b1k8pnn054bvzcn5dm3pkgq595d3gk"))

(define rust-pin-project-lite-0.2.17
  (crate-source "pin-project-lite" "0.2.17"
                "1kfmwvs271si96zay4mm8887v5khw0c27jc9srw1a75ykvgj54x8"))

(define rust-piper-0.2.5
  (crate-source "piper" "0.2.5"
                "1hd3j94mw5dwc457gs9ssb2r5b9iipywndf5srqx7pj38jd4fdf8"))

(define rust-pkg-config-0.3.32
  (crate-source "pkg-config" "0.3.32"
                "0k4h3gnzs94sjb2ix6jyksacs52cf1fanpwsmlhjnwrdnp8dppby"))

(define rust-polling-3.11.0
  (crate-source "polling" "3.11.0"
                "0622qfbxi3gb0ly2c99n3xawp878fkrd1sl83hjdhisx11cly3jx"))

(define rust-poly1305-0.8.0
  (crate-source "poly1305" "0.8.0"
                "1grs77skh7d8vi61ji44i8gpzs3r9x7vay50i6cg8baxfa8bsnc1"))

(define rust-polyval-0.6.2
  (crate-source "polyval" "0.6.2"
                "09gs56vm36ls6pyxgh06gw2875z2x77r8b2km8q28fql0q6yc7wx"))

(define rust-powerfmt-0.2.0
  (crate-source "powerfmt" "0.2.0"
                "14ckj2xdpkhv3h6l5sdmb9f1d57z8hbfpdldjc2vl5givq2y77j3"))

(define rust-ppv-lite86-0.2.21
  (crate-source "ppv-lite86" "0.2.21"
                "1abxx6qz5qnd43br1dd9b2savpihzjza8gb4fbzdql1gxp2f7sl5"))

(define rust-prctl-1.0.0
  (crate-source "prctl" "1.0.0"
                "0lkgnid3sjfbqf3sbcgyihlw80a6n9l6m0n23b7f5pm927qk96h5"))

(define rust-predicates-3.1.4
  (crate-source "predicates" "3.1.4"
                "1ziwwshyl5d7yf9anyb8ldamqrx0kv1w3mhdnzkpx8i85y9z5a5d"))

(define rust-predicates-core-1.0.10
  (crate-source "predicates-core" "1.0.10"
                "0i6ia05imr1fsppc1z2lg0g2kpalz7crmlx0n4ql0sqnyd38glya"))

(define rust-predicates-tree-1.0.13
  (crate-source "predicates-tree" "1.0.13"
                "1wp2farzvl4aarpa3sdq59bd1rk0zzqrszj6n0fi7j1rgf21ppnh"))

(define rust-prettyplease-0.2.37
  (crate-source "prettyplease" "0.2.37"
                "0azn11i1kh0byabhsgab6kqs74zyrg69xkirzgqyhz6xmjnsi727"))

(define rust-proc-macro-crate-3.5.0
  (crate-source "proc-macro-crate" "3.5.0"
                "0kv1g1d1zjwxlgcaba2qlshzyy32j03xic8rskqlcr5mnblsfyz6"))

(define rust-proc-macro-error-1.0.4
  (crate-source "proc-macro-error" "1.0.4"
                "1373bhxaf0pagd8zkyd03kkx6bchzf6g0dkwrwzsnal9z47lj9fs"))

(define rust-proc-macro-error-attr-1.0.4
  (crate-source "proc-macro-error-attr" "1.0.4"
                "0sgq6m5jfmasmwwy8x4mjygx5l7kp8s4j60bv25ckv2j1qc41gm1"))

(define rust-proc-macro-hack-0.4.3
  (crate-source "proc-macro-hack" "0.4.3"
                "1qlfck1fiwrj0wdv71z06bm0alpfsyq9pywfzx2cr607b145dyfp"))

(define rust-proc-macro-hack-impl-0.4.3
  (crate-source "proc-macro-hack-impl" "0.4.3"
                "09q0jvdm5g0balskv9q446l9h7k3bk0fzmnxqzbz8d8nmvq5prbv"))

(define rust-proc-macro2-1.0.106
  (crate-source "proc-macro2" "1.0.106"
                "0d09nczyaj67x4ihqr5p7gxbkz38gxhk4asc0k8q23g9n85hzl4g"))

(define rust-quick-xml-0.37.5
  (crate-source "quick-xml" "0.37.5"
                "1yxpd7rc2qn6f4agfj47ps2z89vv7lvzxpzawqirix8bmyhrf7ik"))

(define rust-quote-0.3.15
  (crate-source "quote" "0.3.15"
                "0yhnnix4dzsv8y4wwz4csbnqjfh73al33j35msr10py6cl5r4vks"))

(define rust-quote-1.0.45
  (crate-source "quote" "1.0.45"
                "095rb5rg7pbnwdp6v8w5jw93wndwyijgci1b5lw8j1h5cscn3wj1"))

(define rust-r-efi-6.0.0
  (crate-source "r-efi" "6.0.0"
                "1gyrl2k5fyzj9k7kchg2n296z5881lg7070msabid09asp3wkp7q"))

(define rust-rand-0.8.5
  (crate-source "rand" "0.8.5"
                "013l6931nn7gkc23jz5mm3qdhf93jjf0fg64nz2lp4i51qd8vbrl"))

(define rust-rand-chacha-0.3.1
  (crate-source "rand_chacha" "0.3.1"
                "123x2adin558xbhvqb8w4f6syjsdkmqff8cxwhmjacpsl1ihmhg6"))

(define rust-rand-core-0.6.4
  (crate-source "rand_core" "0.6.4"
                "0b4j2v4cb5krak1pv6kakv4sz6xcwbrmy2zckc32hsigbrwy82zc"))

(define rust-redox-users-0.4.6
  (crate-source "redox_users" "0.4.6"
                "0hya2cxx6hxmjfxzv9n8rjl5igpychav7zfi1f81pz6i4krry05s"))

(define rust-rusb-0.8.1
  (crate-source "rusb" "0.8.1"
                "1b80icrc7amkg1mz1cwi4hprslfcw1g3w2vm3ixyfnyc5130i9fr"))

(define rust-rustc-version-0.4.1
  (crate-source "rustc_version" "0.4.1"
                "14lvdsmr5si5qbqzrajgb6vfn69k0sfygrvfvr2mps26xwi3mjyg"))

(define rust-rustix-1.1.4
  (crate-source "rustix" "1.1.4"
                "14511f9yjqh0ix07xjrjpllah3325774gfwi9zpq72sip5jlbzmn"))

(define rust-rustversion-1.0.22
  (crate-source "rustversion" "1.0.22"
                "0vfl70jhv72scd9rfqgr2n11m5i9l1acnk684m2w83w0zbqdx75k"))

(define rust-salsa20-0.10.2
  (crate-source "salsa20" "0.10.2"
                "04w211x17xzny53f83p8f7cj7k2hi8zck282q5aajwqzydd2z8lp"))

(define rust-semver-1.0.27
  (crate-source "semver" "1.0.27"
                "1qmi3akfrnqc2hfkdgcxhld5bv961wbk8my3ascv5068mc5fnryp"))

(define rust-serde-1.0.228
  (crate-source "serde" "1.0.228"
                "17mf4hhjxv5m90g42wmlbc61hdhlm6j9hwfkpcnd72rpgzm993ls"))

(define rust-serde-core-1.0.228
  (crate-source "serde_core" "1.0.228"
                "1bb7id2xwx8izq50098s5j2sqrrvk31jbbrjqygyan6ask3qbls1"))

(define rust-serde-derive-1.0.228
  (crate-source "serde_derive" "1.0.228"
                "0y8xm7fvmr2kjcd029g9fijpndh8csv5m20g4bd76w8qschg4h6m"))

(define rust-serde-json-1.0.149
  (crate-source "serde_json" "1.0.149"
                "11jdx4vilzrjjd1dpgy67x5lgzr0laplz30dhv75lnf5ffa07z43"))

(define rust-serde-repr-0.1.20
  (crate-source "serde_repr" "0.1.20"
                "1755gss3f6lwvv23pk7fhnjdkjw7609rcgjlr8vjg6791blf6php"))

(define rust-sha-1-0.9.8
  (crate-source "sha-1" "0.9.8"
                "19jibp8l9k5v4dnhj5kfhaczdfd997h22qz0hin6pw9wvc9ngkcr"))

(define rust-sha-1-0.10.1
  (crate-source "sha-1" "0.10.1"
                "1700fs5aiiailpd5h0ax4sgs2ngys0mqf3p4j0ry6j2p2zd8l1gm"))

(define rust-shlex-1.3.0
  (crate-source "shlex" "1.3.0"
                "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))

(define rust-signal-hook-registry-1.4.8
  (crate-source "signal-hook-registry" "1.4.8"
                "06vc7pmnki6lmxar3z31gkyg9cw7py5x9g7px70gy2hil75nkny4"))

(define rust-slab-0.4.12
  (crate-source "slab" "0.4.12"
                "1xcwik6s6zbd3lf51kkrcicdq2j4c1fw0yjdai2apy9467i0sy8c"))

(define rust-slog-2.8.2
  (crate-source "slog" "2.8.2"
                "1hcmd6fzkxqqjy6sv31cbw6gqdzq93njcr06zjyx48hvd5jqafwv"))

(define rust-slog-term-2.9.2
  (crate-source "slog-term" "2.9.2"
                "1d891y1lr41l1af4xalnikdq2b4xq1qkhay0skxddviq1dlgrcaw"))

(define rust-strsim-0.10.0
  (crate-source "strsim" "0.10.0"
                "08s69r4rcrahwnickvi0kq49z524ci50capybln83mg6b473qivk"))

(define rust-structure-0.1.2
  (crate-source "structure" "0.1.2"
                "0ngss4aylxg0pjwj8x5pv159hvh92ldikn8lic0mp4zqkkmrldx8"))

(define rust-structure-macro-impl-0.1.2
  (crate-source "structure-macro-impl" "0.1.2"
                "1jksyxhp7z83rxm6x427pps8f03hgymzz3v8g1cbpj194jgm5h70"))

(define rust-strum-0.28.0
  (crate-source "strum" "0.28.0"
                "1ggr0if083c1mz9w33hkdjsp0iqk2fz9n49bvb73knwihydxwa4n"))

(define rust-strum-macros-0.28.0
  (crate-source "strum_macros" "0.28.0"
                "0r7n6v5b3x85m52isyc8wq78irmr22g0hmj1xn3pbq8f4yhfx1db"))

(define rust-subtle-2.4.1
  (crate-source "subtle" "2.4.1"
                "00b6jzh9gzb0h9n25g06nqr90z3xzqppfhhb260s1hjhh4pg7pkb"))

(define rust-syn-1.0.109
  (crate-source "syn" "1.0.109"
                "0ds2if4600bd59wsv7jjgfkayfzy3hnazs394kz6zdkmna8l3dkj"))

(define rust-syn-2.0.117
  (crate-source "syn" "2.0.117"
                "16cv7c0wbn8amxc54n4w15kxlx5ypdmla8s0gxr2l7bv7s0bhrg6"))

(define rust-sysinfo-0.38.4
  (crate-source "sysinfo" "0.38.4"
                "0bx5wjp16cyckr9c0fxzrfcx54g4aa15f1k47kmqsl7yicpnmawj"))

(define rust-tabwriter-1.4.1
  (crate-source "tabwriter" "1.4.1"
                "0ch4823i90iw35an0g000f3ii8cs8dkv5gnbddzgyzf81qpizsgw"))

(define rust-tauri-winrt-notification-0.7.2
  (crate-source "tauri-winrt-notification" "0.7.2"
                "1fd9gcllx1rkp9h1ppq976bhqppnil5xsy36li1zx2g4gph6c7hb"))

(define rust-tempfile-3.27.0
  (crate-source "tempfile" "3.27.0"
                "1gblhnyfjsbg9wjg194n89wrzah7jy3yzgnyzhp56f3v9jd7wj9j"))

(define rust-term-1.2.1
  (crate-source "term" "1.2.1"
                "1qgp7kcsh7q7b967hz4nzklly7wsgipzg64bq3zrjqran5vp3hnq"))

(define rust-termcolor-1.4.1
  (crate-source "termcolor" "1.4.1"
                "0mappjh3fj3p2nmrg4y7qv94rchwi9mzmgmfflr8p2awdj7lyy86"))

(define rust-termtree-0.5.1
  (crate-source "termtree" "0.5.1"
                "10s610ax6nb70yi7xfmwcb6d3wi9sj5isd0m63gy2pizr2zgwl4g"))

(define rust-textwrap-0.16.2
  (crate-source "textwrap" "0.16.2"
                "0mrhd8q0dnh5hwbwhiv89c6i41yzmhw4clwa592rrp24b9hlfdf1"))

(define rust-thiserror-1.0.69
  (crate-source "thiserror" "1.0.69"
                "0lizjay08agcr5hs9yfzzj6axs53a2rgx070a1dsi3jpkcrzbamn"))

(define rust-thiserror-2.0.18
  (crate-source "thiserror" "2.0.18"
                "1i7vcmw9900bvsmay7mww04ahahab7wmr8s925xc083rpjybb222"))

(define rust-thiserror-impl-1.0.69
  (crate-source "thiserror-impl" "1.0.69"
                "1h84fmn2nai41cxbhk6pqf46bxqq1b344v8yz089w1chzi76rvjg"))

(define rust-thiserror-impl-2.0.18
  (crate-source "thiserror-impl" "2.0.18"
                "1mf1vrbbimj1g6dvhdgzjmn6q09yflz2b92zs1j9n3k7cxzyxi7b"))

(define rust-thread-local-1.1.9
  (crate-source "thread_local" "1.1.9"
                "1191jvl8d63agnq06pcnarivf63qzgpws5xa33hgc92gjjj4c0pn"))

(define rust-time-0.3.47
  (crate-source "time" "0.3.47"
                "0b7g9ly2iabrlgizliz6v5x23yq5d6bpp0mqz6407z1s526d8fvl"))

(define rust-time-core-0.1.8
  (crate-source "time-core" "0.1.8"
                "1jidl426mw48i7hjj4hs9vxgd9lwqq4vyalm4q8d7y4iwz7y353n"))

(define rust-time-macros-0.2.27
  (crate-source "time-macros" "0.2.27"
                "058ja265waq275wxvnfwavbz9r1hd4dgwpfn7a1a9a70l32y8w1f"))

(define rust-toml-datetime-1.0.1+spec-1.1.0
  (crate-source "toml_datetime" "1.0.1+spec-1.1.0"
                "1sgk7zc6x187iib7kj1nzn44mp0zrk9hgii69rbar35m3ms0wclv"))

(define rust-toml-edit-0.25.5+spec-1.1.0
  (crate-source "toml_edit" "0.25.5+spec-1.1.0"
                "1qgjkq687jkdrc3wq4fi95lj6d0bvwqs9xi3d41wx2x28h3a98cc"))

(define rust-toml-parser-1.0.10+spec-1.1.0
  (crate-source "toml_parser" "1.0.10+spec-1.1.0"
                "081lsv63zphnff9ssb0yjavcc82sblvj808rvwb4h76kxx5mpwkx"))

(define rust-tracing-0.1.44
  (crate-source "tracing" "0.1.44"
                "006ilqkg1lmfdh3xhg3z762izfwmxcvz0w7m4qx2qajbz9i1drv3"))

(define rust-tracing-attributes-0.1.31
  (crate-source "tracing-attributes" "0.1.31"
                "1np8d77shfvz0n7camx2bsf1qw0zg331lra0hxb4cdwnxjjwz43l"))

(define rust-tracing-core-0.1.36
  (crate-source "tracing-core" "0.1.36"
                "16mpbz6p8vd6j7sf925k9k8wzvm9vdfsjbynbmaxxyq6v7wwm5yv"))

(define rust-typenum-1.19.0
  (crate-source "typenum" "1.19.0"
                "1fw2mpbn2vmqan56j1b3fbpcdg80mz26fm53fs16bq5xcq84hban"))

(define rust-uds-windows-1.2.1
  (crate-source "uds_windows" "1.2.1"
                "0vidqwwfgn8wyzvbxiqil787b4wyqjia50zpdbbjqx7n8wlgpxpj"))

(define rust-unicode-ident-1.0.24
  (crate-source "unicode-ident" "1.0.24"
                "0xfs8y1g7syl2iykji8zk5hgfi5jw819f5zsrbaxmlzwsly33r76"))

(define rust-unicode-width-0.2.2
  (crate-source "unicode-width" "0.2.2"
                "0m7jjzlcccw716dy9423xxh0clys8pfpllc5smvfxrzdf66h9b5l"))

(define rust-unicode-xid-0.2.6
  (crate-source "unicode-xid" "0.2.6"
                "0lzqaky89fq0bcrh6jj6bhlz37scfd8c7dsj5dq7y32if56c1hgb"))

(define rust-universal-hash-0.5.1
  (crate-source "universal-hash" "0.5.1"
                "1sh79x677zkncasa95wz05b36134822w6qxmi1ck05fwi33f47gw"))

(define rust-uuid-1.22.0
  (crate-source "uuid" "1.22.0"
                "0dvsfn44sddhyhlhk7m3i559wyb125h86799fm5abky0067kr3d6"))

(define rust-vcpkg-0.2.15
  (crate-source "vcpkg" "0.2.15"
                "09i4nf5y8lig6xgj3f7fyrvzd3nlaw4znrihw8psidvv5yk4xkdc"))

(define rust-version-check-0.9.5
  (crate-source "version_check" "0.9.5"
                "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))

(define rust-wasi-0.11.1+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.1+wasi-snapshot-preview1"
                "0jx49r7nbkbhyfrfyhz0bm4817yrnxgd3jiwwwfv0zl439jyrwyc"))

(define rust-wasip2-1.0.2+wasi-0.2.9
  (crate-source "wasip2" "1.0.2+wasi-0.2.9"
                "1xdw7v08jpfjdg94sp4lbdgzwa587m5ifpz6fpdnkh02kwizj5wm"))

(define rust-wasip3-0.4.0+wasi-0.3.0-rc-2026-01-06
  (crate-source "wasip3" "0.4.0+wasi-0.3.0-rc-2026-01-06"
                "19dc8p0y2mfrvgk3qw3c3240nfbylv22mvyxz84dqpgai2zzha2l"))

(define rust-wasm-bindgen-0.2.114
  (crate-source "wasm-bindgen" "0.2.114"
                "13nkhw552hpllrrmkd2x9y4bmcxr82kdpky2n667kqzcq6jzjck5"))

(define rust-wasm-bindgen-macro-0.2.114
  (crate-source "wasm-bindgen-macro" "0.2.114"
                "1rhq9kkl7n0zjrag9p25xsi4aabpgfkyf02zn4xv6pqhrw7xb8hq"))

(define rust-wasm-bindgen-macro-support-0.2.114
  (crate-source "wasm-bindgen-macro-support" "0.2.114"
                "1qriqqjpn922kv5c7f7627fj823k5aifv06j2gvwsiy5map4rkh3"))

(define rust-wasm-bindgen-shared-0.2.114
  (crate-source "wasm-bindgen-shared" "0.2.114"
                "05lc6w64jxlk4wk8rjci4z61lhx2ams90la27a41gvi3qaw2d8vm"))

(define rust-wasm-encoder-0.244.0
  (crate-source "wasm-encoder" "0.244.0"
                "06c35kv4h42vk3k51xjz1x6hn3mqwfswycmr6ziky033zvr6a04r"))

(define rust-wasm-metadata-0.244.0
  (crate-source "wasm-metadata" "0.244.0"
                "02f9dhlnryd2l7zf03whlxai5sv26x4spfibjdvc3g9gd8z3a3mv"))

(define rust-wasmparser-0.244.0
  (crate-source "wasmparser" "0.244.0"
                "1zi821hrlsxfhn39nqpmgzc0wk7ax3dv6vrs5cw6kb0v5v3hgf27"))

(define rust-which-8.0.2
  (crate-source "which" "8.0.2"
                "0nf4c067qvw5zzk0lr9iadzfnaprr9kkrj0cgmxf8smgmapmz6c1"))

(define rust-winapi-0.3.9
  (crate-source "winapi" "0.3.9"
                "06gl025x418lchw1wxj64ycr7gha83m44cjr5sarhynd9xkrm0sw"))

(define rust-winapi-i686-pc-windows-gnu-0.4.0
  (crate-source "winapi-i686-pc-windows-gnu" "0.4.0"
                "1dmpa6mvcvzz16zg6d5vrfy4bxgg541wxrcip7cnshi06v38ffxc"))

(define rust-winapi-util-0.1.11
  (crate-source "winapi-util" "0.1.11"
                "08hdl7mkll7pz8whg869h58c1r9y7in0w0pk8fm24qc77k0b39y2"))

(define rust-winapi-x86-64-pc-windows-gnu-0.4.0
  (crate-source "winapi-x86_64-pc-windows-gnu" "0.4.0"
                "0gqq64czqb64kskjryj8isp62m2sgvx25yyj3kpc2myh85w24bki"))

(define rust-windows-0.61.3
  (crate-source "windows" "0.61.3"
                "14v8dln7i4ccskd8danzri22bkjkbmgzh284j3vaxhd4cykx7awv"))

(define rust-windows-0.62.2
  (crate-source "windows" "0.62.2"
                "10457l9ihrbw8j79z2v4plyjxkf6xvb5npd0lqwmkh702gpaszsj"))

(define rust-windows-collections-0.2.0
  (crate-source "windows-collections" "0.2.0"
                "1s65anr609qvsjga7w971p6iq964h87670dkfqfypnfgwnswxviv"))

(define rust-windows-collections-0.3.2
  (crate-source "windows-collections" "0.3.2"
                "0436rjbkqn3j9m2v2lcmwwk0l3n2r57yvqb7fcy4m8d8y5ddkci3"))

(define rust-windows-core-0.61.2
  (crate-source "windows-core" "0.61.2"
                "1qsa3iw14wk4ngfl7ipcvdf9xyq456ms7cx2i9iwf406p7fx7zf0"))

(define rust-windows-core-0.62.2
  (crate-source "windows-core" "0.62.2"
                "1swxpv1a8qvn3bkxv8cn663238h2jccq35ff3nsj61jdsca3ms5q"))

(define rust-windows-future-0.2.1
  (crate-source "windows-future" "0.2.1"
                "13mdzcdn51ckpzp3frb8glnmkyjr1c30ym9wnzj9zc97hkll2spw"))

(define rust-windows-future-0.3.2
  (crate-source "windows-future" "0.3.2"
                "1jq5qs2dwzf6rl60f8gr49z2mifxsrdh4y4yfdws467ya41gkmp1"))

(define rust-windows-implement-0.60.2
  (crate-source "windows-implement" "0.60.2"
                "1psxhmklzcf3wjs4b8qb42qb6znvc142cb5pa74rsyxm1822wgh5"))

(define rust-windows-interface-0.59.3
  (crate-source "windows-interface" "0.59.3"
                "0n73cwrn4247d0axrk7gjp08p34x1723483jxjxjdfkh4m56qc9z"))

(define rust-windows-link-0.1.3
  (crate-source "windows-link" "0.1.3"
                "12kr1p46dbhpijr4zbwr2spfgq8i8c5x55mvvfmyl96m01cx4sjy"))

(define rust-windows-link-0.2.1
  (crate-source "windows-link" "0.2.1"
                "1rag186yfr3xx7piv5rg8b6im2dwcf8zldiflvb22xbzwli5507h"))

(define rust-windows-numerics-0.2.0
  (crate-source "windows-numerics" "0.2.0"
                "1cf2j8nbqf0hqqa7chnyid91wxsl2m131kn0vl3mqk3c0rlayl4i"))

(define rust-windows-numerics-0.3.1
  (crate-source "windows-numerics" "0.3.1"
                "09hgbg8pf89r4090yyhh9q29ppi7yyxkgmga9ascshy19a240bkf"))

(define rust-windows-result-0.3.4
  (crate-source "windows-result" "0.3.4"
                "1il60l6idrc6hqsij0cal0mgva6n3w6gq4ziban8wv6c6b9jpx2n"))

(define rust-windows-result-0.4.1
  (crate-source "windows-result" "0.4.1"
                "1d9yhmrmmfqh56zlj751s5wfm9a2aa7az9rd7nn5027nxa4zm0bp"))

(define rust-windows-strings-0.4.2
  (crate-source "windows-strings" "0.4.2"
                "0mrv3plibkla4v5kaakc2rfksdd0b14plcmidhbkcfqc78zwkrjn"))

(define rust-windows-strings-0.5.1
  (crate-source "windows-strings" "0.5.1"
                "14bhng9jqv4fyl7lqjz3az7vzh8pw0w4am49fsqgcz67d67x0dvq"))

(define rust-windows-sys-0.61.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.61.2"
                "1z7k3y9b6b5h52kid57lvmvm05362zv1v8w0gc7xyv5xphlp44xf"))

(define rust-windows-threading-0.1.0
  (crate-source "windows-threading" "0.1.0"
                "19jpn37zpjj2q7pn07dpq0ay300w65qx7wdp13wbp8qf5snn6r5n"))

(define rust-windows-threading-0.2.1
  (crate-source "windows-threading" "0.2.1"
                "0dsvsy33vxs0153z4n39sqkzx382cjjkrd46rb3z3zfak5dvsj9r"))

(define rust-windows-version-0.1.7
  (crate-source "windows-version" "0.1.7"
                "0c9nnqpcq770977k77mw1p66gpw45khwhqkjdcrd1f89l4fhl1p4"))

(define rust-winnow-0.7.15
  (crate-source "winnow" "0.7.15"
                "0i9rkl2rqpbnnxlgs20gmkj3nd0b2k8q55mjmpc2ybb84xwxjyfz"))

(define rust-winnow-1.0.0
  (crate-source "winnow" "1.0.0"
                "1n67gx8mg2b6r2z54zwbrb6qsfbdsar1lvafsfaajr3jcvj8h3m9"))

(define rust-wit-bindgen-0.51.0
  (crate-source "wit-bindgen" "0.51.0"
                "19fazgch8sq5cvjv3ynhhfh5d5x08jq2pkw8jfb05vbcyqcr496p"))

(define rust-wit-bindgen-core-0.51.0
  (crate-source "wit-bindgen-core" "0.51.0"
                "1p2jszqsqbx8k7y8nwvxg65wqzxjm048ba5phaq8r9iy9ildwqga"))

(define rust-wit-bindgen-rust-0.51.0
  (crate-source "wit-bindgen-rust" "0.51.0"
                "08bzn5fsvkb9x9wyvyx98qglknj2075xk1n7c5jxv15jykh6didp"))

(define rust-wit-bindgen-rust-macro-0.51.0
  (crate-source "wit-bindgen-rust-macro" "0.51.0"
                "0ymizapzv2id89igxsz2n587y2hlfypf6n8kyp68x976fzyrn3qc"))

(define rust-wit-component-0.244.0
  (crate-source "wit-component" "0.244.0"
                "1clwxgsgdns3zj2fqnrjcp8y5gazwfa1k0sy5cbk0fsmx4hflrlx"))

(define rust-wit-parser-0.244.0
  (crate-source "wit-parser" "0.244.0"
                "0dm7avvdxryxd5b02l0g5h6933z1cw5z0d4wynvq2cywq55srj7c"))

(define rust-yubico-manager-0.9.0
  (crate-source "yubico_manager" "0.9.0"
                "1vlf0vpfma3gfhlpdss9fhhmsispyakkzn9vd2w3cy7j3110jr7z"))

(define rust-zbus-5.14.0
  (crate-source "zbus" "5.14.0"
                "1g305kwnw9f420c6m10i40cjdjm2s31ddpngac5a8hrrpmfzk0na"))

(define rust-zbus-macros-5.14.0
  (crate-source "zbus_macros" "5.14.0"
                "08ljsjl1zhpzdf7hx37yaifi14rvysj354bfqjrc9al4drhpjzl9"))

(define rust-zbus-names-4.3.1
  (crate-source "zbus_names" "4.3.1"
                "03y5f8xwzmk4y5wb4g95a1hl48mxlmhcbwqz62mrnqbqbdnszn7z"))

(define rust-zerocopy-0.8.47
  (crate-source "zerocopy" "0.8.47"
                "11zdl3708210fsiax93qbvw8kiadg9lnzriw26xg44g35c32mfzg"))

(define rust-zerocopy-derive-0.8.47
  (crate-source "zerocopy-derive" "0.8.47"
                "12dbrk2w8mszdq9v01ls930bi446iyk4llggxrx8whalkckcg2qf"))

(define rust-zeroize-1.8.2
  (crate-source "zeroize" "1.8.2"
                "1l48zxgcv34d7kjskr610zqsm6j2b4fcr2vfh9jm9j1jgvk58wdr"))

(define rust-zmij-1.0.21
  (crate-source "zmij" "1.0.21"
                "1amb5i6gz7yjb0dnmz5y669674pqmwbj44p4yfxfv2ncgvk8x15q"))

(define rust-zvariant-5.10.0
  (crate-source "zvariant" "5.10.0"
                "02sls8pi570z1wssl150413x0mcwqhi9ywlliqsbwfwh46djj22p"))

(define rust-zvariant-derive-5.10.0
  (crate-source "zvariant_derive" "5.10.0"
                "0b3mh0kzf6sz7vd5j9gimq86awjcigddh26cz5b6di79xc9b0nav"))

(define rust-zvariant-utils-3.3.0
  (crate-source "zvariant_utils" "3.3.0"
                "1sf5i71in36gc08jhak83pprnkam8gk936cqlq9hzx7q9sk26p7p"))


(define ssss-separator 'end-of-crates)

;;;
;;; Cargo inputs.
;;;

(define-cargo-inputs lookup-cargo-inputs
                     (git-credential-keepassxc =>
                                               (list
                                                rust-aead-0.5.2
                                                rust-aes-0.7.5
                                                rust-aes-0.8.4
                                                rust-aes-gcm-0.10.3
                                                rust-android-system-properties-0.1.5
                                                rust-anstyle-1.0.14
                                                rust-anyhow-1.0.102
                                                rust-async-broadcast-0.7.2
                                                rust-async-channel-2.5.0
                                                rust-async-executor-1.14.0
                                                rust-async-io-2.6.0
                                                rust-async-lock-3.4.2
                                                rust-async-process-2.5.0
                                                rust-async-recursion-1.1.1
                                                rust-async-signal-0.2.13
                                                rust-async-task-4.7.1
                                                rust-async-trait-0.1.89
                                                rust-atomic-waker-1.1.2
                                                rust-atty-0.2.14
                                                rust-autocfg-1.5.0
                                                rust-base64-0.22.1
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.11.0
                                                rust-block-buffer-0.9.0
                                                rust-block-buffer-0.10.4
                                                rust-block-modes-0.8.1
                                                rust-block-padding-0.2.1
                                                rust-block2-0.6.2
                                                rust-blocking-1.6.2
                                                rust-bumpalo-3.20.2
                                                rust-byteorder-1.5.0
                                                rust-cc-1.2.57
                                                rust-cfg-if-1.0.4
                                                rust-cfg-aliases-0.2.1
                                                rust-chrono-0.4.44
                                                rust-cipher-0.3.0
                                                rust-cipher-0.4.4
                                                rust-clap-3.2.25
                                                rust-clap-derive-3.2.25
                                                rust-clap-lex-0.2.4
                                                rust-concurrent-queue-2.5.0
                                                rust-core-foundation-sys-0.8.7
                                                rust-cpufeatures-0.2.17
                                                rust-crossbeam-utils-0.8.21
                                                rust-crypto-common-0.1.7
                                                rust-crypto-mac-0.11.1
                                                rust-crypto-box-0.9.1
                                                rust-crypto-secretbox-0.1.1
                                                rust-ctr-0.9.2
                                                rust-curve25519-dalek-4.1.3
                                                rust-curve25519-dalek-derive-0.1.1
                                                rust-deranged-0.5.8
                                                rust-digest-0.9.0
                                                rust-digest-0.10.7
                                                rust-directories-next-2.0.0
                                                rust-dirs-sys-next-0.1.2
                                                rust-dispatch2-0.3.1
                                                rust-downcast-0.11.0
                                                rust-endi-1.1.1
                                                rust-enumflags2-0.7.12
                                                rust-enumflags2-derive-0.7.12
                                                rust-equivalent-1.0.2
                                                rust-erased-serde-0.3.31
                                                rust-errno-0.3.14
                                                rust-event-listener-5.4.1
                                                rust-event-listener-strategy-0.5.4
                                                rust-fastrand-2.3.0
                                                rust-fiat-crypto-0.2.9
                                                rust-find-msvc-tools-0.1.9
                                                rust-foldhash-0.1.5
                                                rust-fragile-2.0.1
                                                rust-futures-core-0.3.32
                                                rust-futures-io-0.3.32
                                                rust-futures-lite-2.6.1
                                                rust-generic-array-0.14.7
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.4.2
                                                rust-ghash-0.5.1
                                                rust-hashbrown-0.12.3
                                                rust-hashbrown-0.15.5
                                                rust-hashbrown-0.16.1
                                                rust-heck-0.4.1
                                                rust-heck-0.5.0
                                                rust-hermit-abi-0.1.19
                                                rust-hermit-abi-0.5.2
                                                rust-hex-0.4.3
                                                rust-hmac-0.11.0
                                                rust-hmac-0.12.1
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-id-arena-2.3.0
                                                rust-indexmap-1.9.3
                                                rust-indexmap-2.13.0
                                                rust-inout-0.1.4
                                                rust-is-terminal-0.4.17
                                                rust-itoa-1.0.18
                                                rust-js-sys-0.3.91
                                                rust-leb128fmt-0.1.0
                                                rust-libc-0.2.183
                                                rust-libredox-0.1.14
                                                rust-libusb1-sys-0.5.0
                                                rust-linux-raw-sys-0.12.1
                                                rust-log-0.4.29
                                                rust-mac-notification-sys-0.6.12
                                                rust-memchr-2.8.0
                                                rust-memoffset-0.9.1
                                                rust-mockall-0.14.0
                                                rust-mockall-derive-0.14.0
                                                rust-named-pipe-0.4.1
                                                rust-nix-0.31.2
                                                rust-notify-rust-4.12.0
                                                rust-ntapi-0.4.3
                                                rust-num-conv-0.2.0
                                                rust-num-traits-0.2.19
                                                rust-num-enum-0.7.6
                                                rust-num-enum-derive-0.7.6
                                                rust-objc2-0.6.4
                                                rust-objc2-core-foundation-0.3.2
                                                rust-objc2-encode-4.1.0
                                                rust-objc2-foundation-0.3.2
                                                rust-objc2-io-kit-0.3.2
                                                rust-once-cell-1.21.4
                                                rust-opaque-debug-0.3.1
                                                rust-ordered-stream-0.2.0
                                                rust-os-str-bytes-6.6.1
                                                rust-parking-2.2.1
                                                rust-pin-project-lite-0.2.17
                                                rust-piper-0.2.5
                                                rust-pkg-config-0.3.32
                                                rust-polling-3.11.0
                                                rust-poly1305-0.8.0
                                                rust-polyval-0.6.2
                                                rust-powerfmt-0.2.0
                                                rust-ppv-lite86-0.2.21
                                                rust-prctl-1.0.0
                                                rust-predicates-3.1.4
                                                rust-predicates-core-1.0.10
                                                rust-predicates-tree-1.0.13
                                                rust-prettyplease-0.2.37
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro-error-1.0.4
                                                rust-proc-macro-error-attr-1.0.4
                                                rust-proc-macro-hack-0.4.3
                                                rust-proc-macro-hack-impl-0.4.3
                                                rust-proc-macro2-1.0.106
                                                rust-quick-xml-0.37.5
                                                rust-quote-0.3.15
                                                rust-quote-1.0.45
                                                rust-r-efi-6.0.0
                                                rust-rand-0.8.5
                                                rust-rand-chacha-0.3.1
                                                rust-rand-core-0.6.4
                                                rust-redox-users-0.4.6
                                                rust-rusb-0.8.1
                                                rust-rustc-version-0.4.1
                                                rust-rustix-1.1.4
                                                rust-rustversion-1.0.22
                                                rust-salsa20-0.10.2
                                                rust-semver-1.0.27
                                                rust-serde-1.0.228
                                                rust-serde-core-1.0.228
                                                rust-serde-derive-1.0.228
                                                rust-serde-json-1.0.149
                                                rust-serde-repr-0.1.20
                                                rust-sha-1-0.9.8
                                                rust-sha-1-0.10.1
                                                rust-shlex-1.3.0
                                                rust-signal-hook-registry-1.4.8
                                                rust-slab-0.4.12
                                                rust-slog-2.8.2
                                                rust-slog-term-2.9.2
                                                rust-strsim-0.10.0
                                                rust-structure-0.1.2
                                                rust-structure-macro-impl-0.1.2
                                                rust-strum-0.28.0
                                                rust-strum-macros-0.28.0
                                                rust-subtle-2.4.1
                                                rust-syn-1.0.109
                                                rust-syn-2.0.117
                                                rust-sysinfo-0.38.4
                                                rust-tabwriter-1.4.1
                                                rust-tauri-winrt-notification-0.7.2
                                                rust-tempfile-3.27.0
                                                rust-term-1.2.1
                                                rust-termcolor-1.4.1
                                                rust-termtree-0.5.1
                                                rust-textwrap-0.16.2
                                                rust-thiserror-1.0.69
                                                rust-thiserror-2.0.18
                                                rust-thiserror-impl-1.0.69
                                                rust-thiserror-impl-2.0.18
                                                rust-thread-local-1.1.9
                                                rust-time-0.3.47
                                                rust-time-core-0.1.8
                                                rust-time-macros-0.2.27
                                                rust-toml-datetime-1.0.1+spec-1.1.0
                                                rust-toml-edit-0.25.5+spec-1.1.0
                                                rust-toml-parser-1.0.10+spec-1.1.0
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-typenum-1.19.0
                                                rust-uds-windows-1.2.1
                                                rust-unicode-ident-1.0.24
                                                rust-unicode-width-0.2.2
                                                rust-unicode-xid-0.2.6
                                                rust-universal-hash-0.5.1
                                                rust-uuid-1.22.0
                                                rust-vcpkg-0.2.15
                                                rust-version-check-0.9.5
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasip2-1.0.2+wasi-0.2.9
                                                rust-wasip3-0.4.0+wasi-0.3.0-rc-2026-01-06
                                                rust-wasm-bindgen-0.2.114
                                                rust-wasm-bindgen-macro-0.2.114
                                                rust-wasm-bindgen-macro-support-0.2.114
                                                rust-wasm-bindgen-shared-0.2.114
                                                rust-wasm-encoder-0.244.0
                                                rust-wasm-metadata-0.244.0
                                                rust-wasmparser-0.244.0
                                                rust-which-8.0.2
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.11
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.61.3
                                                rust-windows-0.62.2
                                                rust-windows-collections-0.2.0
                                                rust-windows-collections-0.3.2
                                                rust-windows-core-0.61.2
                                                rust-windows-core-0.62.2
                                                rust-windows-future-0.2.1
                                                rust-windows-future-0.3.2
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.1.3
                                                rust-windows-link-0.2.1
                                                rust-windows-numerics-0.2.0
                                                rust-windows-numerics-0.3.1
                                                rust-windows-result-0.3.4
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.4.2
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.61.2
                                                rust-windows-threading-0.1.0
                                                rust-windows-threading-0.2.1
                                                rust-windows-version-0.1.7
                                                rust-winnow-0.7.15
                                                rust-winnow-1.0.0
                                                rust-wit-bindgen-0.51.0
                                                rust-wit-bindgen-core-0.51.0
                                                rust-wit-bindgen-rust-0.51.0
                                                rust-wit-bindgen-rust-macro-0.51.0
                                                rust-wit-component-0.244.0
                                                rust-wit-parser-0.244.0
                                                rust-yubico-manager-0.9.0
                                                rust-zbus-5.14.0
                                                rust-zbus-macros-5.14.0
                                                rust-zbus-names-4.3.1
                                                rust-zerocopy-0.8.47
                                                rust-zerocopy-derive-0.8.47
                                                rust-zeroize-1.8.2
                                                rust-zmij-1.0.21
                                                rust-zvariant-5.10.0
                                                rust-zvariant-derive-5.10.0
                                                rust-zvariant-utils-3.3.0
)))
