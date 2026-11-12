;;; SPDX-FileCopyrightText: 2025 Hilton Chain <hako@ultrarare.space>
;;; SPDX-FileCopyrightText: 2025 Gabriel Santos <gabrielsantosdesouza@disroot.org>
;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-or-later

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
  #:use-module (guix git-download)
  #:use-module (guix packages)
  #:export (lookup-cargo-inputs))

;;;
;;; This file is managed by 'guix import'.  Do NOT add definitions manually.
;;;

;;;
;;; Rust libraries fetched from crates.io and non-workspace development
;;; snapshots.
;;;

(define qqqq-separator 'begin-of-crates)

(define rust-accesskit-0.21.1
  (crate-source "accesskit" "0.21.1"
                "16balg6n7gyg05z7wm4a4iczf66z53vbw7rxhfc9zwnq7ffky86g"))

(define rust-accesskit-atspi-common-0.14.2
  (crate-source "accesskit_atspi_common" "0.14.2"
                "0rw25av7v66c1wdckix6kp9zh8blhky4vhssmkq89iqzylf283c9"))

(define rust-accesskit-consumer-0.31.0
  (crate-source "accesskit_consumer" "0.31.0"
                "0hyx2z5xbaql81hx54vif4xv8y850yccxrkjj1zp1n4md05030fv"))

(define rust-accesskit-unix-0.17.2
  (crate-source "accesskit_unix" "0.17.2"
                "0a65zsa5yn14lkpyil00cxj5398449bmzkj3i72dj5gwkjrma7ih"))

(define rust-adler2-2.0.1
  (crate-source "adler2" "2.0.1"
                "1ymy18s9hs7ya1pjc9864l30wk8p2qfqdi7mhhcc5nfakxbij09j"))

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

(define rust-ahash-0.8.12
  (crate-source "ahash" "0.8.12"
                "0xbsp9rlm5ki017c0w6ay8kjwinwm8knjncci95mii30rmwz25as"))

(define rust-aho-corasick-1.1.4
  (crate-source "aho-corasick" "1.1.4"
                "00a32wb2h07im3skkikc495jvncf62jl6s96vwc7bhi70h9imlyx"))

(define rust-aliasable-0.1.3
  (crate-source "aliasable" "0.1.3"
                "1z8548zdjlm4ps1k0d7x68lfdyji02crwcc9rw3q3bb106f643r5"))

(define rust-allocator-api2-0.2.21
  (crate-source "allocator-api2" "0.2.21"
                "08zrzs022xwndihvzdn78yqarv2b9696y67i6h78nla3ww87jgb8"))

(define rust-android-activity-0.6.1
  (crate-source "android-activity" "0.6.1"
                "1k8v4mw8kijvmjmqwr05cjvk2arklx2968bjjpa5szc5aaq1nahg"))

(define rust-android-properties-0.2.2
  (crate-source "android-properties" "0.2.2"
                "016slvg269c0y120p9qd8vdfqa2jbw4j0g18gfw6p3ain44v4zpw"))

(define rust-android-system-properties-0.1.5
  (crate-source "android_system_properties" "0.1.5"
                "04b3wrz12837j7mdczqd95b732gw5q7q66cv4yn4646lvccp57l1"))

(define rust-annotate-snippets-0.11.5
  (crate-source "annotate-snippets" "0.11.5"
                "1i1bmr5vy957l8fvivj9x1xs24np0k56rdgwj0bxqk45b2p8w3ki"))

(define rust-anstream-1.0.0
  (crate-source "anstream" "1.0.0"
                "13d2bj0xfg012s4rmq44zc8zgy1q8k9yp7yhvfnarscnmwpj2jl2"))

(define rust-anstyle-1.0.14
  (crate-source "anstyle" "1.0.14"
                "0030szmgj51fxkic1hpakxxgappxzwm6m154a3gfml83lq63l2wl"))

(define rust-anstyle-parse-1.0.0
  (crate-source "anstyle-parse" "1.0.0"
                "03hkv2690s0crssbnmfkr76kw1k7ah2i6s5amdy9yca2n8w7zkjj"))

(define rust-anstyle-query-1.1.5
  (crate-source "anstyle-query" "1.1.5"
                "1p6shfpnbghs6jsa0vnqd8bb8gd7pjd0jr7w0j8jikakzmr8zi20"))

(define rust-anstyle-wincon-3.0.11
  (crate-source "anstyle-wincon" "3.0.11"
                "0zblannm70sk3xny337mz7c6d8q8i24vhbqi42ld8v7q1wjnl7i9"))

(define rust-anyhow-1.0.102
  (crate-source "anyhow" "1.0.102"
                "0b447dra1v12z474c6z4jmicdmc5yxz5bakympdnij44ckw2s83z"))

(define rust-appendlist-1.4.0
  (crate-source "appendlist" "1.4.0"
                "1lnbl7mc7capcqj1z1ylxvm4h492sb9sr8pzww3q6lrhrmrxqjg1"))

(define rust-approx-0.4.0
  (crate-source "approx" "0.4.0"
                "0y52dg58lapl4pp1kqlznfw1blbki0nx6b0aw8kja2yi3gyhaaiz"))

(define rust-approx-0.5.1
  (crate-source "approx" "0.5.1"
                "1ilpv3dgd58rasslss0labarq7jawxmivk17wsh8wmkdm3q15cfa"))

(define rust-arrayvec-0.7.6
  (crate-source "arrayvec" "0.7.6"
                "0l1fz4ccgv6pm609rif37sl5nv5k6lbzi7kkppgzqzh1vwix20kw"))

(define rust-as-raw-xcb-connection-1.0.1
  (crate-source "as-raw-xcb-connection" "1.0.1"
                "0sqgpz2ymv5yx76r5j2npjq2x5qvvqnw0vrs35cyv30p3pfp2m8p"))

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

(define rust-async-signal-0.2.14
  (crate-source "async-signal" "0.2.14"
                "11dlpb15la279r5cazppy18gbk2xzzl60ahzl19m1kr0l2psmdaj"))

(define rust-async-task-4.7.1
  (crate-source "async-task" "4.7.1"
                "1pp3avr4ri2nbh7s6y9ws0397nkx1zymmcr14sq761ljarh3axcb"))

(define rust-async-trait-0.1.89
  (crate-source "async-trait" "0.1.89"
                "1fsxxmz3rzx1prn1h3rs7kyjhkap60i7xvi0ldapkvbb14nssdch"))

(define rust-atomic-0.6.1
  (crate-source "atomic" "0.6.1"
                "0h43ljcgbl6vk62hs6yk7zg7qn3myzvpw8k7isb9nzhkbdvvz758"))

(define rust-atomic-float-1.1.0
  (crate-source "atomic_float" "1.1.0"
                "02j85l9wf0pycq1ad8rwq6h681nk373jqdchwlpvihwaj67j53b2"))

(define rust-atomic-waker-1.1.2
  (crate-source "atomic-waker" "1.1.2"
                "1h5av1lw56m0jf0fd3bchxq8a30xv0b4wv8s4zkp4s0i7mfvs18m"))

(define rust-atspi-0.25.0
  (crate-source "atspi" "0.25.0"
                "0p412rz8cnsqh1l3wx5zq0ahxvhyg406qcazmy68623m5rc4fcn8"))

(define rust-atspi-common-0.9.0
  (crate-source "atspi-common" "0.9.0"
                "1yzxdkkzzs43aslyysaar7vr93vqyljby0vq3659i46zgigc1prk"))

(define rust-atspi-connection-0.9.0
  (crate-source "atspi-connection" "0.9.0"
                "0f29g39w06dk15hmap2scfv4csr52i3h1q3a0l226cyq0c9xb4s1"))

(define rust-atspi-proxies-0.9.0
  (crate-source "atspi-proxies" "0.9.0"
                "073msx1xrf0xjy56kifvpqrny7ndw6ah4vzxpk82cvz7wywvrvnj"))

(define rust-atty-0.2.14
  (crate-source "atty" "0.2.14"
                "1s7yslcs6a28c5vz7jwj63lkfgyx8mx99fdirlhi9lbhhzhrpcyr"))

(define rust-autocfg-1.5.0
  (crate-source "autocfg" "1.5.0"
                "1s77f98id9l4af4alklmzq46f21c980v13z2r1pcxx6bqgw0d1n0"))

(define rust-base64-0.21.7
  (crate-source "base64" "0.21.7"
                "0rw52yvsk75kar9wgqfwgb414kvil1gn7mqkrhn9zf1537mpsacx"))

(define rust-base64-0.22.1
  (crate-source "base64" "0.22.1"
                "1imqzgh7bxcikp5vx3shqvw9j09g9ly0xr0jma0q66i52r7jbcvj"))

(define rust-bindgen-0.72.1
  (crate-source "bindgen" "0.72.1"
                "15bq73y3wd3x3vxh3z3g72hy08zs8rxg1f0i1xsrrd6g16spcdwr"))

(define rust-bit-set-0.8.0
  (crate-source "bit-set" "0.8.0"
                "18riaa10s6n59n39vix0cr7l2dgwdhcpbcm97x1xbyfp1q47x008"))

(define rust-bit-vec-0.8.0
  (crate-source "bit-vec" "0.8.0"
                "1xxa1s2cj291r7k1whbxq840jxvmdsq9xgh7bvrxl46m80fllxjy"))

(define rust-bitflags-1.3.2
  (crate-source "bitflags" "1.3.2"
                "12ki6w8gn1ldq7yz9y680llwk5gmrhrzszaa17g1sbrw2r2qvwxy"))

(define rust-bitflags-2.11.0
  (crate-source "bitflags" "2.11.0"
                "1bwjibwry5nfwsfm9kjg2dqx5n5nja9xymwbfl6svnn8jsz6ff44"))

(define rust-bitflags-2.11.1
  (crate-source "bitflags" "2.11.1"
                "1cvqijg3rvwgis20a66vfdxannjsxfy5fgjqkaq3l13gyfcj4lf4"))

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

(define rust-block2-0.5.1
  (crate-source "block2" "0.5.1"
                "0pyiha5his2grzqr3mynmq244laql2j20992i59asp0gy7mjw4rc"))

(define rust-block2-0.6.2
  (crate-source "block2" "0.6.2"
                "1xcfllzx6c3jc554nmb5qy6xmlkl6l6j5ib4wd11800n0n3rvsyd"))

(define rust-blocking-1.6.2
  (crate-source "blocking" "1.6.2"
                "08bz3f9agqlp3102snkvsll6wc9ag7x5m1xy45ak2rv9pq18sgz8"))

(define rust-bumpalo-3.20.2
  (crate-source "bumpalo" "3.20.2"
                "1jrgxlff76k9glam0akhwpil2fr1w32gbjdf5hpipc7ld2c7h82x"))

(define rust-bytemuck-1.25.0
  (crate-source "bytemuck" "1.25.0"
                "1v1z32igg9zq49phb3fra0ax5r2inf3aw473vldnm886sx5vdvy8"))

(define rust-bytemuck-derive-1.10.2
  (crate-source "bytemuck_derive" "1.10.2"
                "1zvmjmw1sdmx9znzm4dpbb2yvz9vyim8w6gp4z256l46qqdvvazr"))

(define rust-byteorder-1.5.0
  (crate-source "byteorder" "1.5.0"
                "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))

(define rust-bytes-1.11.1
  (crate-source "bytes" "1.11.1"
                "0czwlhbq8z29wq0ia87yass2mzy1y0jcasjb8ghriiybnwrqfx0y"))

(define rust-cairo-rs-0.21.5
  (crate-source "cairo-rs" "0.21.5"
                "1r679k0wbrxa773cw207wmnhx8sypm4s7pmncbiay5mxq0sy27xh"))

(define rust-cairo-sys-rs-0.21.5
  (crate-source "cairo-sys-rs" "0.21.5"
                "0p14dpy8ar6gqi493nn04w5n7rp438km8icywfsma85iqs085hh6"))

(define rust-calloop-0.13.0
  (crate-source "calloop" "0.13.0"
                "1v5zgidnhsyml403rzr7vm99f8q6r5bxq5gxyiqkr8lcapwa57dr"))

(define rust-calloop-0.14.4
  (crate-source "calloop" "0.14.4"
                "1xsd8xk53v9zbvhjy7ynf4gya9s4rvvh8jqx9psi1b2v6rw9kgsd"))

(define rust-calloop-wayland-source-0.3.0
  (crate-source "calloop-wayland-source" "0.3.0"
                "086x5mq16prrcwd9k6bw9an0sp8bj9l5daz4ziz5z4snf2c6m9lm"))

(define rust-calloop-wayland-source-0.4.1
  (crate-source "calloop-wayland-source" "0.4.1"
                "1yi1c23naqhd8m94q3v366s4cak8l50zy7ldrkqfn0hajkqgr3hk"))

(define rust-cc-1.2.57
  (crate-source "cc" "1.2.57"
                "08q464b62d03zm7rgiixavkrh5lzfq18lwf884vgycj9735d23bs"))

(define rust-cc-1.2.60
  (crate-source "cc" "1.2.60"
                "084a8ziprdlyrj865f3303qr0b7aaggilkl18slncss6m4yp1ia3"))

(define rust-cexpr-0.6.0
  (crate-source "cexpr" "0.6.0"
                "0rl77bwhs5p979ih4r0202cn5jrfsrbgrksp40lkfz5vk1x3ib3g"))

(define rust-cfg-expr-0.20.7
  (crate-source "cfg-expr" "0.20.7"
                "0s4k51p520dk6l5vl08rzv13qc1bk9nm80xcsi71b040gph08srw"))

(define rust-cfg-if-1.0.4
  (crate-source "cfg-if" "1.0.4"
                "008q28ajc546z5p2hcwdnckmg0hia7rnx52fni04bwqkzyrghc4k"))

(define rust-cfg-aliases-0.2.1
  (crate-source "cfg_aliases" "0.2.1"
                "092pxdc1dbgjb6qvh83gk56rkic2n2ybm4yvy76cgynmzi3zwfk1"))

(define rust-cgmath-0.18.0
  (crate-source "cgmath" "0.18.0"
                "05sk7c1c1jg5ygqvc3y77kxddp177gwazfibhd864ag3800x760s"))

(define rust-chrono-0.4.44
  (crate-source "chrono" "0.4.44"
                "1c64mk9a235271j5g3v4zrzqqmd43vp9vki7vqfllpqf5rd0fwy6"))

(define rust-chumsky-0.9.3
  (crate-source "chumsky" "0.9.3"
                "1jcnafc8rjfs1al08gqzyn0kpbaizgdwrd0ajqafspd18ikxdswf"))

(define rust-cipher-0.3.0
  (crate-source "cipher" "0.3.0"
                "1dyzsv0c84rgz98d5glnhsz4320wl24x3bq511vnyf0mxir21rby"))

(define rust-cipher-0.4.4
  (crate-source "cipher" "0.4.4"
                "1b9x9agg67xq5nq879z66ni4l08m6m3hqcshk37d4is4ysd3ngvp"))

(define rust-clang-sys-1.8.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "clang-sys" "1.8.1"
                "1x1r9yqss76z8xwpdanw313ss6fniwc1r7dzb5ycjn0ph53kj0hb"))

(define rust-clap-3.2.25
  (crate-source "clap" "3.2.25"
                "08vi402vfqmfj9f07c4gl6082qxgf4c9x98pbndcnwbgaszq38af"))

(define rust-clap-4.6.1
  (crate-source "clap" "4.6.1"
                "0lcf88l7vlg796rrqr7wipbbmfa5sgsgx4211b7xmxxv8dz13nqx"))

(define rust-clap-builder-4.6.0
  (crate-source "clap_builder" "4.6.0"
                "17q6np22yxhh5y5v53y4l31ps3hlaz45mvz2n2nicr7n3c056jki"))

(define rust-clap-complete-4.6.2
  (crate-source "clap_complete" "4.6.2"
                "1jzr2rl2hl7cjyiks16m6haia5a681zg9gyy5f60g2yxrgfa3xrz"))

(define rust-clap-complete-nushell-4.6.0
  (crate-source "clap_complete_nushell" "4.6.0"
                "15yqhkzndsxbmii8nspbl6qga9mrys4fa6srd2s599r9bmqykfgv"))

(define rust-clap-derive-3.2.25
  (crate-source "clap_derive" "3.2.25"
                "025hh66cyjk5xhhq8s1qw5wkxvrm8hnv5xwwksax7dy8pnw72qxf"))

(define rust-clap-derive-4.6.1
  (crate-source "clap_derive" "4.6.1"
                "1acpz49hi00iv9jkapixjzcv7s51x8qkfaqscjm36rqgf428dkpj"))

(define rust-clap-lex-0.2.4
  (crate-source "clap_lex" "0.2.4"
                "1ib1a9v55ybnaws11l63az0jgz5xiy24jkdgsmyl7grcm3sz4l18"))

(define rust-clap-lex-1.1.0
  (crate-source "clap_lex" "1.1.0"
                "1ycqkpygnlqnndghhcxjb44lzl0nmgsia64x9581030yifxs7m68"))

(define rust-colorchoice-1.0.5
  (crate-source "colorchoice" "1.0.5"
                "0w75k89hw39p0mnnhlrwr23q50rza1yjki44qvh2mgrnj065a1qx"))

(define rust-combine-4.6.7
  (crate-source "combine" "4.6.7"
                "1z8rh8wp59gf8k23ar010phgs0wgf5i8cx4fg01gwcnzfn5k0nms"))

(define rust-concurrent-queue-2.5.0
  (crate-source "concurrent-queue" "2.5.0"
                "0wrr3mzq2ijdkxwndhf79k952cp4zkz35ray8hvsxl96xrx1k82c"))

(define rust-console-0.16.3
  (crate-source "console" "0.16.3"
                "11zwz1vnfr0nx6dyjx0gjymp8864y5hxwf01ynfd2s8kapsqlknn"))

(define rust-convert-case-0.8.0
  (crate-source "convert_case" "0.8.0"
                "17zqy79xlr1n7nc0n1mlnw5qpp8l2nbxrk13jixrhlavrbna1ams"))

(define rust-cookie-factory-0.3.3
  (crate-source "cookie-factory" "0.3.3"
                "18mka6fk3843qq3jw1fdfvzyv05kx7kcmirfbs2vg2kbw9qzm1cq"))

(define rust-core-foundation-0.9.4
  (crate-source "core-foundation" "0.9.4"
                "13zvbbj07yk3b61b8fhwfzhy35535a583irf23vlcg59j7h9bqci"))

(define rust-core-foundation-sys-0.8.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "core-foundation-sys" "0.8.7"
                "12w8j73lazxmr1z0h98hf3z623kl8ms7g07jch7n4p8f9nwlhdkp"))

(define rust-core-graphics-0.23.2
  (crate-source "core-graphics" "0.23.2"
                "10dhv3gk4kmbzl14xxkrhhky4fdp8h6nzff6h0019qgr6nz84xy0"))

(define rust-core-graphics-types-0.1.3
  (crate-source "core-graphics-types" "0.1.3"
                "1bxg8nxc8fk4kxnqyanhf36wq0zrjr552c58qy6733zn2ihhwfa5"))

(define rust-cpufeatures-0.2.17
  (crate-source "cpufeatures" "0.2.17"
                "10023dnnaghhdl70xcds12fsx2b966sxbxjq5sxs49mvxqw5ivar"))

(define rust-crc32fast-1.5.0
  (crate-source "crc32fast" "1.5.0"
                "04d51liy8rbssra92p0qnwjw8i9rm9c4m3bwy19wjamz1k4w30cl"))

(define rust-crossbeam-deque-0.8.6
  (crate-source "crossbeam-deque" "0.8.6"
                "0l9f1saqp1gn5qy0rxvkmz4m6n7fc0b3dbm6q1r5pmgpnyvi3lcx"))

(define rust-crossbeam-epoch-0.9.18
  (crate-source "crossbeam-epoch" "0.9.18"
                "03j2np8llwf376m3fxqx859mgp9f83hj1w34153c7a9c7i5ar0jv"))

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

(define rust-csscolorparser-0.8.3
  (crate-source "csscolorparser" "0.8.3"
                "0lm97nhhcwcad3rrp5yh3r24gh77fizjq9bljk008l6bscdqb7qr"))

(define rust-ctr-0.9.2
  (crate-source "ctr" "0.9.2"
                "0d88b73waamgpfjdml78icxz45d95q7vi2aqa604b0visqdfws83"))

(define rust-cursor-icon-1.2.0
  (crate-source "cursor-icon" "1.2.0"
                "0bvkw7ak1mqwcpkgd9lh7n00hcvlh87jfl7188f231nz6zfy2ypj"))

(define rust-curve25519-dalek-4.1.3
  (crate-source "curve25519-dalek" "4.1.3"
                "1gmjb9dsknrr8lypmhkyjd67p1arb8mbfamlwxm7vph38my8pywp"))

(define rust-curve25519-dalek-derive-0.1.1
  (crate-source "curve25519-dalek-derive" "0.1.1"
                "1cry71xxrr0mcy5my3fb502cwfxy6822k4pm19cwrilrg7hq4s7l"))

(define rust-deranged-0.5.8
  (crate-source "deranged" "0.5.8"
                "0711df3w16vx80k55ivkwzwswziinj4dz05xci3rvmn15g615n3w"))

(define rust-diff-0.1.13
  (crate-source "diff" "0.1.13"
                "1j0nzjxci2zqx63hdcihkp0a4dkdmzxd7my4m7zk6cjyfy34j9an"))

(define rust-digest-0.9.0
  (crate-source "digest" "0.9.0"
                "0rmhvk33rgvd6ll71z8sng91a52rw14p0drjn1da0mqa138n1pfk"))

(define rust-digest-0.10.7
  (crate-source "digest" "0.10.7"
                "14p2n6ih29x81akj097lvz7wi9b6b9hvls0lwrv7b6xwyy0s5ncy"))

(define rust-directories-6.0.0
  (crate-source "directories" "6.0.0"
                "0zgy2w088v8w865c11dmc3dih899fgrhvrfp7g83h6v6ai60kx8n"))

(define rust-directories-next-2.0.0
  (crate-source "directories-next" "2.0.0"
                "1g1vq8d8mv0vp0l317gh9y46ipqg2fxjnbc7lnjhwqbsv4qf37ik"))

(define rust-dirs-sys-0.5.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "dirs-sys" "0.5.0"
                "1aqzpgq6ampza6v012gm2dppx9k35cdycbj54808ksbys9k366p0"))

(define rust-dirs-sys-next-0.1.2
  (crate-source "dirs-sys-next" "0.1.2"
                "0kavhavdxv4phzj4l0psvh55hszwnr0rcz8sxbvx20pyqi2a3gaf"))

(define rust-dispatch-0.2.0
  (crate-source "dispatch" "0.2.0"
                "0fwjr9b7582ic5689zxj8lf7zl94iklhlns3yivrnv8c9fxr635x"))

(define rust-dispatch2-0.3.1
  (crate-source "dispatch2" "0.3.1"
                "0f5xmnbzpaz1g80m27kd804p75nswh0ikb6wvqh4ba3x9rz3c3hy"))

(define rust-dlib-0.5.3
  (crate-source "dlib" "0.5.3"
                "0jpr4smrwrv8xj70mz4ixnbc6ljm82f12z2mz1hv89056y3wv3mb"))

(define rust-downcast-0.11.0
  (crate-source "downcast" "0.11.0"
                "1wa78ahlc57wmqyq2ncr80l7plrkgz57xsg7kfzgpcnqac8gld8l"))

(define rust-downcast-rs-1.2.1
  (crate-source "downcast-rs" "1.2.1"
                "1lmrq383d1yszp7mg5i7i56b17x2lnn3kb91jwsq0zykvg2jbcvm"))

(define rust-dpi-0.1.2
  (crate-source "dpi" "0.1.2"
                "0xhsvzgjvdch2fwmfc9vkb708b0q59b6imypyjlgbiigyb74rcfq"))

(define rust-drm-0.14.1
  (crate-source "drm" "0.14.1"
                "0vvmj9n0wslrbw3rinpzlfyhwwgr02gqspy1al5gfh99dif8rg40"))

(define rust-drm-ffi-0.9.1
  (crate-source "drm-ffi" "0.9.1"
                "147n13dnkr4kzdj4662dqgbjfvnnw14yhmf2vq2q2kmc6adiraai"))

(define rust-drm-fourcc-2.2.0
  (crate-source "drm-fourcc" "2.2.0"
                "1x76v9a0pkgym4n6cah4barnai9gsssm7gjzxskw2agwibdvrbqa"))

(define rust-drm-sys-0.8.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "drm-sys" "0.8.1"
                "1y59h9x5yn9p36f9bqjvw76kx75yqfin1w6gzigiznb620vf3j7c"))

(define rust-dyn-clone-1.0.20
  (crate-source "dyn-clone" "1.0.20"
                "0m956cxcg8v2n8kmz6xs5zl13k2fak3zkapzfzzp7pxih6hix26h"))

(define rust-either-1.15.0
  (crate-source "either" "1.15.0"
                "069p1fknsmzn9llaizh77kip0pqmcwpdsykv2x30xpjyija5gis8"))

(define rust-encode-unicode-1.0.0
  (crate-source "encode_unicode" "1.0.0"
                "1h5j7j7byi289by63s3w4a8b3g6l5ccdrws7a67nn07vdxj77ail"))

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

(define rust-fastrand-2.4.1
  (crate-source "fastrand" "2.4.1"
                "1mnqxxnxvd69ma9mczabpbbsgwlhd6l78yv3vd681453a9s247wz"))

(define rust-fdeflate-0.3.7
  (crate-source "fdeflate" "0.3.7"
                "130ga18vyxbb5idbgi07njymdaavvk6j08yh1dfarm294ssm6s0y"))

(define rust-fiat-crypto-0.2.9
  (crate-source "fiat-crypto" "0.2.9"
                "07c1vknddv3ak7w89n85ik0g34nzzpms6yb845vrjnv9m4csbpi8"))

(define rust-field-offset-0.3.6
  (crate-source "field-offset" "0.3.6"
                "0zq5sssaa2ckmcmxxbly8qgz3sxpb8g1lwv90sdh1z74qif2gqiq"))

(define rust-find-msvc-tools-0.1.9
  (crate-source "find-msvc-tools" "0.1.9"
                "10nmi0qdskq6l7zwxw5g56xny7hb624iki1c39d907qmfh3vrbjv"))

(define rust-flate2-1.1.9
  (crate-source "flate2" "1.1.9"
                "0g2pb7cxnzcbzrj8bw4v6gpqqp21aycmf6d84rzb6j748qkvlgw4"))

(define rust-fnv-1.0.7
  (crate-source "fnv" "1.0.7"
                "1hc2mcqha06aibcaza94vbi81j6pr9a1bbxrxjfhc91zin8yr7iz"))

(define rust-foldhash-0.1.5
  (crate-source "foldhash" "0.1.5"
                "1wisr1xlc2bj7hk4rgkcjkz3j2x4dhd1h9lwk7mj8p71qpdgbi6r"))

(define rust-foreign-types-0.5.0
  (crate-source "foreign-types" "0.5.0"
                "0rfr2zfxnx9rz3292z5nyk8qs2iirznn5ff3rd4vgdwza6mdjdyp"))

(define rust-foreign-types-macros-0.2.3
  (crate-source "foreign-types-macros" "0.2.3"
                "0hjpii8ny6l7h7jpns2cp9589016l8mlrpaigcnayjn9bdc6qp0s"))

(define rust-foreign-types-shared-0.3.1
  (crate-source "foreign-types-shared" "0.3.1"
                "0nykdvv41a3d4py61bylmlwjhhvdm0b3bcj9vxhqgxaxnp5ik6ma"))

(define rust-fragile-2.0.1
  (crate-source "fragile" "2.0.1"
                "06g69s9w3hmdnjp5b60ph15v367278mgxy1shijrllarc2pnrp98"))

(define rust-futures-channel-0.3.32
  (crate-source "futures-channel" "0.3.32"
                "07fcyzrmbmh7fh4ainilf1s7gnwvnk07phdq77jkb9fpa2ffifq7"))

(define rust-futures-core-0.3.32
  (crate-source "futures-core" "0.3.32"
                "07bbvwjbm5g2i330nyr1kcvjapkmdqzl4r6mqv75ivvjaa0m0d3y"))

(define rust-futures-executor-0.3.32
  (crate-source "futures-executor" "0.3.32"
                "17aplz3ns74qn7a04qg7qlgsdx5iwwwkd4jvdfra6hl3h4w9rwms"))

(define rust-futures-io-0.3.32
  (crate-source "futures-io" "0.3.32"
                "063pf5m6vfmyxj74447x8kx9q8zj6m9daamj4hvf49yrg9fs7jyf"))

(define rust-futures-lite-2.6.1
  (crate-source "futures-lite" "2.6.1"
                "1ba4dg26sc168vf60b1a23dv1d8rcf3v3ykz2psb7q70kxh113pp"))

(define rust-futures-macro-0.3.32
  (crate-source "futures-macro" "0.3.32"
                "0ys4b1lk7s0bsj29pv42bxsaavalch35rprp64s964p40c1bfdg8"))

(define rust-futures-task-0.3.32
  (crate-source "futures-task" "0.3.32"
                "14s3vqf8llz3kjza33vn4ixg6kwxp61xrysn716h0cwwsnri2xq3"))

(define rust-futures-util-0.3.32
  (crate-source "futures-util" "0.3.32"
                "1mn60lw5kh32hz9isinjlpw34zx708fk5q1x0m40n6g6jq9a971q"))

(define rust-gbm-0.18.0
  (crate-source "gbm" "0.18.0"
                "0skyaj51xlazaa24jdkxxi2g6pnw834k3yqlf2ly999wincjx1ff"))

(define rust-gbm-sys-0.4.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gbm-sys" "0.4.0"
                "0vzp28ip4w74p05ygs4p9m7sspggn2zvcykbpyv8ypbqrhm5yfn1"))

(define rust-gdk-pixbuf-0.21.5
  (crate-source "gdk-pixbuf" "0.21.5"
                "0350zm38d7sf3ilnwy9fxyhajbdslvjdcm7xxlk4dn6dwcwhvfyy"))

(define rust-gdk-pixbuf-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk-pixbuf-sys" "0.21.5"
                "1rqc1bv3ln6hx4a4bn3jagz75dzhmy96hkyx4lg5blm3p58av5dx"))

(define rust-gdk4-0.10.3
  (crate-source "gdk4" "0.10.3"
                "1gxzhk55r0nh48ld7l1j700cc6jqh8jvvzw8bph4qjmy5chn8rbm"))

(define rust-gdk4-sys-0.10.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk4-sys" "0.10.3"
                "0d5hk2agfifnn0hgcjyb4lcrvrdlaxgkzj6w99m854gmrjrybm56"))

(define rust-generator-0.8.8
  (crate-source "generator" "0.8.8"
                "1ybcxxz9vdh7nyh9q5654zv5q790b63a83w0zrv0r8id2pj4mw2j"))

(define rust-generic-array-0.14.7
  (crate-source "generic-array" "0.14.7"
                "16lyyrzrljfq424c3n8kfwkqihlimmsg5nhshbbp48np3yjrqr45"))

(define rust-gethostname-1.1.0
  (crate-source "gethostname" "1.1.0"
                "1n6bj9gh503ggjblfjcai96gmxynxsrykaynljlrfdra34q95m0v"))

(define rust-getrandom-0.2.17
  (crate-source "getrandom" "0.2.17"
                "1l2ac6jfj9xhpjjgmcx6s1x89bbnw9x6j9258yy6xjkzpq0bqapz"))

(define rust-getrandom-0.3.4
  (crate-source "getrandom" "0.3.4"
                "1zbpvpicry9lrbjmkd4msgj3ihff1q92i334chk7pzf46xffz7c9"))

(define rust-getrandom-0.4.2
  (crate-source "getrandom" "0.4.2"
                "0mb5833hf9pvn9dhvxjgfg5dx0m77g8wavvjdpvpnkp9fil1xr8d"))

(define rust-ghash-0.5.1
  (crate-source "ghash" "0.5.1"
                "1wbg4vdgzwhkpkclz1g6bs4r5x984w5gnlsj4q5wnafb5hva9n7h"))

(define rust-gio-0.21.5
  (crate-source "gio" "0.21.5"
                "06l1nlq5r0dvm0xmhrpgvs8ypx7jcb3vgihxwrvb8s0cc2zlizy5"))

(define rust-gio-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gio-sys" "0.21.5"
                "08hgv0lqm94hyhdisjrl52bg9699c9ibp6zzr2301r58vf4gww80"))

(define rust-git-version-0.3.9
  (crate-source "git-version" "0.3.9"
                "06ddi3px6l2ip0srn8512bsh8wrx4rzi65piya0vrz5h7nm6im8s"))

(define rust-git-version-macro-0.3.9
  (crate-source "git-version-macro" "0.3.9"
                "1h1s08fgh9bkwnc2hmjxcldv69hlxpq7a09cqdxsd5hb235hq0ak"))

(define rust-gl-generator-0.14.0
  (crate-source "gl_generator" "0.14.0"
                "0k8j1hmfnff312gy7x1aqjzcm8zxid7ij7dlb8prljib7b1dz58s"))

(define rust-glam-0.32.1
  (crate-source "glam" "0.32.1"
                "186cjxn5qknagm31vmxvxk1kwwrfvv6cqj99nvvcngh6bdllj1zp"))

(define rust-glib-0.21.5
  (crate-source "glib" "0.21.5"
                "12xxy5js4bfpjz9k6831xj090r5y37g30wrvawxwx43c5qy15phn"))

(define rust-glib-macros-0.21.5
  (crate-source "glib-macros" "0.21.5"
                "05vzv1m4dg1cpkakxk3n1846acv4fhwhghq1zsbaca0j61svcnfg"))

(define rust-glib-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "glib-sys" "0.21.5"
                "0v1ymxb51sbwv242slq21kbn8g38j2day53f52kn9r4sl6iy359d"))

(define rust-glob-0.3.3
  (crate-source "glob" "0.3.3"
                "106jpd3syfzjfj2k70mwm0v436qbx96wig98m4q8x071yrq35hhc"))

(define rust-gobject-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gobject-sys" "0.21.5"
                "157jv8ga4f7p4vrn4mmg84lrl0ly3kz9kjzkfm2qz88r1pd3bjid"))

(define rust-graphene-rs-0.21.5
  (crate-source "graphene-rs" "0.21.5"
                "1yg23ws354622ya5qccwvf9gpjn188vhkrz1pzc3yrnvr4506c17"))

(define rust-graphene-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "graphene-sys" "0.21.5"
                "14zxhk20yypksyh8kx14xf5ddhjifcmzcjh49cg29bd93q4k4pli"))

(define rust-gsk4-0.10.3
  (crate-source "gsk4" "0.10.3"
                "0lx17acgawg9xn216lgikcdpy1lxjvhqk2q2mazcb5jqijfxwmg7"))

(define rust-gsk4-sys-0.10.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gsk4-sys" "0.10.3"
                "1xzlf8yidajc86cm7fcmn5br11lgdn3l242z0s1g8ihi75r19sbw"))

(define rust-gtk4-0.10.3
  (crate-source "gtk4" "0.10.3"
                "1971514d9kadzj61rn28fgc4gjk77g2335sl8fpvzxy6rx9ivcmc"))

(define rust-gtk4-macros-0.10.3
  (crate-source "gtk4-macros" "0.10.3"
                "0hiy02q0gnfqg1bj8iycb5xmgm0jz80q2psxh521551x9ahvbkrw"))

(define rust-gtk4-sys-0.10.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gtk4-sys" "0.10.3"
                "1pc803r3921h44pa773qpirn3aqcrq2fibykdhb5vq8ybbz7f9c4"))

(define rust-hashbrown-0.12.3
  (crate-source "hashbrown" "0.12.3"
                "1268ka4750pyg2pbgsr43f0289l5zah4arir2k4igx5a8c6fg7la"))

(define rust-hashbrown-0.14.5
  (crate-source "hashbrown" "0.14.5"
                "1wa1vy1xs3mp11bn3z9dv0jricgr6a2j0zkf1g19yz3vw4il89z5"))

(define rust-hashbrown-0.15.5
  (crate-source "hashbrown" "0.15.5"
                "189qaczmjxnikm9db748xyhiw04kpmhm9xj9k9hg0sgx7pjwyacj"))

(define rust-hashbrown-0.16.1
  (crate-source "hashbrown" "0.16.1"
                "004i3njw38ji3bzdp9z178ba9x3k0c1pgy8x69pj7yfppv4iq7c4"))

(define rust-hashbrown-0.17.0
  (crate-source "hashbrown" "0.17.0"
                "0l8gvcz80lvinb7x22h53cqbi2y1fm603y2jhhh9qwygvkb7sijg"))

(define rust-heck-0.4.1
  (crate-source "heck" "0.4.1"
                "1a7mqsnycv5z4z5vnv1k34548jzmc0ajic7c1j8jsaspnhw5ql4m"))

(define rust-heck-0.5.0
  (crate-source "heck" "0.5.0"
                "1sjmpsdl8czyh9ywl3qcsfsq9a307dg4ni2vnlwgnzzqhc4y0113"))

(define rust-hermit-abi-0.1.19
  (crate-source "hermit-abi" "0.1.19"
                "0cxcm8093nf5fyn114w8vxbrbcyvv91d4015rdnlgfll7cs6gd32"))

(define rust-hermit-abi-0.3.9
  (crate-source "hermit-abi" "0.3.9"
                "092hxjbjnq5fmz66grd9plxd0sh6ssg5fhgwwwqbrzgzkjwdycfj"))

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

(define rust-indexmap-2.14.0
  (crate-source "indexmap" "2.14.0"
                "1na9z6f0d5pkjr1lgsni470v98gv2r7c41j8w48skr089x2yjrnl"))

(define rust-inout-0.1.4
  (crate-source "inout" "0.1.4"
                "008xfl1jn9rxsq19phnhbimccf4p64880jmnpg59wqi07kk117w7"))

(define rust-input-0.10.0
  (crate-source "input" "0.10.0"
                "17cmlwa5z6z3x47r7m78vmh8f7rmv2sncc53cdvk2waxlr2k6ygr"))

(define rust-input-sys-1.19.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "input-sys" "1.19.0"
                "1rqrrglhgyyiy7xh8jvf9jwh2dyk2g7l5rmjaazrbg82iryy1vin"))

(define rust-insta-1.47.2
  (crate-source "insta" "1.47.2"
                "0kh9gspras3vhvx8wkygnw2wzlwjln7gwzgks8g4194kxd464jkv"))

(define rust-io-lifetimes-1.0.11
  (crate-source "io-lifetimes" "1.0.11"
                "1hph5lz4wd3drnn6saakwxr497liznpfnv70via6s0v8x6pbkrza"))

(define rust-is-ci-1.2.0
  (crate-source "is_ci" "1.2.0"
                "0ifwvxmrsj4r29agfzr71bjq6y1bihkx38fbzafq5vl0jn1wjmbn"))

(define rust-is-terminal-0.4.17
  (crate-source "is-terminal" "0.4.17"
                "0ilfr9n31m0k6fsm3gvfrqaa62kbzkjqpwcd9mc46klfig1w2h1n"))

(define rust-is-terminal-polyfill-1.70.2
  (crate-source "is_terminal_polyfill" "1.70.2"
                "15anlc47sbz0jfs9q8fhwf0h3vs2w4imc030shdnq54sny5i7jx6"))

(define rust-itertools-0.13.0
  (crate-source "itertools" "0.13.0"
                "11hiy3qzl643zcigknclh446qb9zlg4dpdzfkjaa9q9fqpgyfgj1"))

(define rust-itoa-1.0.18
  (crate-source "itoa" "1.0.18"
                "10jnd1vpfkb8kj38rlkn2a6k02afvj3qmw054dfpzagrpl6achlg"))

(define rust-jni-0.22.4
  (crate-source "jni" "0.22.4"
                "161lza8gz071h22pgyqyx4n91ixd691z2dbb1pq2g97k5i49mzay"))

(define rust-jni-macros-0.22.4
  (crate-source "jni-macros" "0.22.4"
                "18v02mcn5c7mb2yw6r930xg6ynsn7hwkxv8z2kdhn3qprjn0j0d0"))

(define rust-jni-sys-0.3.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "jni-sys" "0.3.1"
                "0n1j8fbz081w1igfrpc79n6vgm7h3ik34nziy5fjgq5nz7hm59j1"))

(define rust-jni-sys-0.4.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "jni-sys" "0.4.1"
                "1wlahx6f2zhczdjqyn8mk7kshb8x5vsd927sn3lvw41rrf47ldy6"))

(define rust-jni-sys-macros-0.4.1
  (crate-source "jni-sys-macros" "0.4.1"
                "0r32gbabrak15a7p487765b5wc0jcna2yv88mk6m1zjqyi1bkh1q"))

(define rust-jobserver-0.1.34
  (crate-source "jobserver" "0.1.34"
                "0cwx0fllqzdycqn4d6nb277qx5qwnmjdxdl0lxkkwssx77j3vyws"))

(define rust-js-sys-0.3.91
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.91"
                "171rzgq33wc1nxkgnvhlqqwwnrifs13mg3jjpjj5nf1z0yvib5xl"))

(define rust-js-sys-0.3.95
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.95"
                "1jhj3kgxxgwm0cpdjiz7i2qapqr7ya9qswadmr63dhwx3lnyjr19"))

(define rust-keyframe-1.1.1
  (crate-source "keyframe" "1.1.1"
                "1afr5ffns3k79xaqnw6rw3qn8sngwly6gxfnjn8d060mk3vqnw30"))

(define rust-khronos-api-3.1.0
  (crate-source "khronos_api" "3.1.0"
                "1p0xj5mlbagqyvvnv8wmv3cr7l9y1m153888pxqwg3vk3mg5inz2"))

(define rust-knuffel-3.2.0
  (crate-source "knuffel" "3.2.0"
                "04vl2xmdn280rcigv96v06a00v7gbxqggr0w9cqi2407qvfydgh4"))

(define rust-knuffel-derive-3.2.0
  (crate-source "knuffel-derive" "3.2.0"
                "0g98909l5wb1d1hcz61q53kvsmjadry2w3l47lg9dywwqib7z5wi"))

(define rust-lazy-static-1.5.0
  (crate-source "lazy_static" "1.5.0"
                "1zk6dqqni0193xg6iijh7i3i44sryglwgvx20spdvwk3r6sbrlmv"))

(define rust-leb128fmt-0.1.0
  (crate-source "leb128fmt" "0.1.0"
                "1chxm1484a0bly6anh6bd7a99sn355ymlagnwj3yajafnpldkv89"))

(define rust-libadwaita-0.8.1
  (crate-source "libadwaita" "0.8.1"
                "0js8slasp2y4zr4hqjbqpp70rk38fq59v0sw66rl4czpz0my22gv"))

(define rust-libadwaita-sys-0.8.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libadwaita-sys" "0.8.1"
                "0c9y9azfdnbnpxvjy514fd87sdafy28j9nnazsbbazm8gci98zvd"))

(define rust-libc-0.2.183
  (crate-source "libc" "0.2.183"
                "17c9gyia7rrzf9gsssvk3vq9ca2jp6rh32fsw6ciarpn5djlddmm"))

(define rust-libc-0.2.185
  (crate-source "libc" "0.2.185"
                "13rbdaa59l3w92q7kfcxx8zbikm99zzw54h59aqvcv5wx47jrzsj"))

(define rust-libdisplay-info-0.3.0
  (crate-source "libdisplay-info" "0.3.0"
                "0nf3c4rpdhgpr8g7dn2wrjyzwl45vz5sq1sg64gz67rqnbdrdzar"))

(define rust-libdisplay-info-derive-0.1.1
  (crate-source "libdisplay-info-derive" "0.1.1"
                "162ahw5kry0d7yf50b62dhw18s6c9bkdjim4409fj6aqrw8cghld"))

(define rust-libdisplay-info-sys-0.3.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libdisplay-info-sys" "0.3.0"
                "07xmkc2aqcdn6d58321y87rd3gzdr4nx3ncm1mmrr7w1p1ahsn96"))

(define rust-libloading-0.8.9
  (crate-source "libloading" "0.8.9"
                "0mfwxwjwi2cf0plxcd685yxzavlslz7xirss3b9cbrzyk4hv1i6p"))

(define rust-libm-0.2.16
  (crate-source "libm" "0.2.16"
                "10brh0a3qjmbzkr5mf5xqi887nhs5y9layvnki89ykz9xb1wxlmn"))

(define rust-libredox-0.1.14
  (crate-source "libredox" "0.1.14"
                "02p3pxlqf54znf1jhiyyjs0i4caf8ckrd5l8ygs4i6ba3nfy6i0p"))

(define rust-libredox-0.1.16
  (crate-source "libredox" "0.1.16"
                "0v54zvgknag9310wcjykgv86pgq02qr3mzgkdg4r6m1k7ns3nbz0"))

(define rust-libseat-0.2.4
  (crate-source "libseat" "0.2.4"
                "0cggn682xklm5h7i8bbjc48wjpys9wz2y8xa7ywgyrh3dsdwcmk6"))

(define rust-libseat-sys-0.2.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libseat-sys" "0.2.0"
                "1yvx15lx8qj3xycdx4ddzs681ayhg5vpdvgzsfl64pxy93x89978"))

(define rust-libspa-0.9.2
  (crate-source "libspa" "0.9.2"
                "1x0dq254f60vva671css7mkwsfj357wrwsrcr6s2frk5lyiczf5n"))

(define rust-libspa-sys-0.9.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libspa-sys" "0.9.2"
                "1q66vim2wha1rdglqn5w0i42z59pa9s5s8sqj37xxdifbm2lj44h"))

(define rust-libudev-sys-0.1.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libudev-sys" "0.1.4"
                "09236fdzlx9l0dlrsc6xx21v5x8flpfm3d5rjq9jr5ivlas6k11w"))

(define rust-libusb1-sys-0.5.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libusb1-sys" "0.5.0"
                "0gq27za2av9gvdz1pgwlzaw3bflyhlxj0inlqp31cs5yig88jbp2"))

(define rust-linux-raw-sys-0.12.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.12.1"
                "0lwasljrqxjjfk9l2j8lyib1babh2qjlnhylqzl01nihw14nk9ij"))

(define rust-linux-raw-sys-0.4.15
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.4.15"
                "1aq7r2g7786hyxhv40spzf2nhag5xbw2axxc1k8z5k1dsgdm4v6j"))

(define rust-linux-raw-sys-0.9.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.9.4"
                "04kyjdrq79lz9ibrf7czk6cv9d3jl597pb9738vzbsbzy1j5i56d"))

(define rust-log-0.4.29
  (crate-source "log" "0.4.29"
                "15q8j9c8g5zpkcw0hnd6cf2z7fxqnvsjh3rw5mv5q10r83i34l2y"))

(define rust-loom-0.7.2
  (crate-source "loom" "0.7.2"
                "1jpszf9qxv8ydpsm2h9vcyvxvyxcfkhmmfbylzd4gfbc0k40v7j1"))

(define rust-mac-notification-sys-0.6.12
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "mac-notification-sys" "0.6.12"
                "1lq7zfxwhixs7npp05lhqvxjq4dj7v6wjcw1ijdq8iqsvn1ng899"))

(define rust-matchers-0.2.0
  (crate-source "matchers" "0.2.0"
                "1sasssspdj2vwcwmbq3ra18d3qniapkimfcbr47zmx6750m5llni"))

(define rust-memchr-2.8.0
  (crate-source "memchr" "2.8.0"
                "0y9zzxcqxvdqg6wyag7vc3h0blhdn7hkq164bxyx2vph8zs5ijpq"))

(define rust-memmap2-0.9.10
  (crate-source "memmap2" "0.9.10"
                "1qz0n4ch68pz2mp07sdwnk27imdjjqy6aqir3hp9j4g0iw19hh3i"))

(define rust-memoffset-0.9.1
  (crate-source "memoffset" "0.9.1"
                "12i17wh9a9plx869g7j4whf62xw68k5zd4k0k5nh6ys5mszid028"))

(define rust-miette-5.10.0
  (crate-source "miette" "5.10.0"
                "0vl5qvl3bgha6nnkdl7kiha6v4ypd6d51wyc4q1bvdpamr75ifsr"))

(define rust-miette-derive-5.10.0
  (crate-source "miette-derive" "5.10.0"
                "0p33msrngkxlp5ajm8nijamii9vcwwpy8gfh4m53qnmrc0avrrs9"))

(define rust-minimal-lexical-0.2.1
  (crate-source "minimal-lexical" "0.2.1"
                "16ppc5g84aijpri4jzv14rvcnslvlpphbszc7zzp6vfkddf4qdb8"))

(define rust-miniz-oxide-0.8.9
  (crate-source "miniz_oxide" "0.8.9"
                "05k3pdg8bjjzayq3rf0qhpirq9k37pxnasfn4arbs17phqn6m9qz"))

(define rust-mockall-0.14.0
  (crate-source "mockall" "0.14.0"
                "02v2gfdz5s927hqsz9qh6lchhiyh5wvyb6077nvcdyd5k109d3gm"))

(define rust-mockall-derive-0.14.0
  (crate-source "mockall_derive" "0.14.0"
                "1gvddfzazipxi8mcn0iqrljzqq2jxrwam1dki3hrnsnsdmqwwhfa"))

(define rust-named-pipe-0.4.1
  (crate-source "named_pipe" "0.4.1"
                "0azby10wzmsrf66m1bysbil0sjfybnvhsa8py093xz4irqy4975d"))

(define rust-ndk-0.9.0
  (crate-source "ndk" "0.9.0"
                "1m32zpmi5w1pf3j47k6k5fw395dc7aj8d0mdpsv53lqkprxjxx63"))

(define rust-ndk-context-0.1.1
  (crate-source "ndk-context" "0.1.1"
                "12sai3dqsblsvfd1l1zab0z6xsnlha3xsfl7kagdnmj3an3jvc17"))

(define rust-ndk-sys-0.6.0+11769913
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "ndk-sys" "0.6.0+11769913"
                "0wx8r6pji20if4xs04g73gxl98nmjrfc73z0v6w1ypv6a4qdlv7f"))

(define rust-nix-0.30.1
  (crate-source "nix" "0.30.1"
                "1dixahq9hk191g0c2ydc0h1ppxj0xw536y6rl63vlnp06lx3ylkl"))

(define rust-nix-0.31.2
  (crate-source "nix" "0.31.2"
                "1lzmcqcnb9z8l4aq5ympx71bcwc0y5yf7d8jv6hnn7hc682hfvax"))

(define rust-nom-7.1.3
  (crate-source "nom" "7.1.3"
                "0jha9901wxam390jcf5pfa0qqfrgh8li787jx2ip0yk5b8y9hwyj"))

(define rust-nom-8.0.0
  (crate-source "nom" "8.0.0"
                "01cl5xng9d0gxf26h39m0l8lprgpa00fcc75ps1yzgbib1vn35yz"))

(define rust-notify-rust-4.12.0
  (crate-source "notify-rust" "4.12.0"
                "1hn6zpvl471gv0c9hkb870fa2lyscflg2jppc5carr8bnnhj1br1"))

(define rust-ntapi-0.4.3
  (crate-source "ntapi" "0.4.3"
                "1bl0d73avwla7laa4pkqvzvifjbs0avg65w01zxjydgx3likbcy3"))

(define rust-nu-ansi-term-0.50.3
  (crate-source "nu-ansi-term" "0.50.3"
                "1ra088d885lbd21q1bxgpqdlk1zlndblmarn948jz2a40xsbjmvr"))

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

(define rust-objc-sys-0.3.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "objc-sys" "0.3.5"
                "0423gry7s3rmz8s3pzzm1zy5mdjif75g6dbzc2lf2z0c77fipffd"))

(define rust-objc2-0.5.2
  (crate-source "objc2" "0.5.2"
                "015qa2d3vh7c1j2736h5wjrznri7x5ic35vl916c22gzxva8b9s6"))

(define rust-objc2-0.6.4
  (crate-source "objc2" "0.6.4"
                "17x8qpl512frscfqbmgjr20kg3y4r0xdqxphja17dz5f0znsh4is"))

(define rust-objc2-app-kit-0.2.2
  (crate-source "objc2-app-kit" "0.2.2"
                "1zqyi5l1bm26j1bgmac9783ah36m5kcrxlqp5carglnpwgcrms74"))

(define rust-objc2-cloud-kit-0.2.2
  (crate-source "objc2-cloud-kit" "0.2.2"
                "02dhjvmcq8c2bwj31jx423jygif1scs9f0lmlab0ayhw75b3ppbl"))

(define rust-objc2-contacts-0.2.2
  (crate-source "objc2-contacts" "0.2.2"
                "12a8m927xrrxa54xhqhqnkkl1a6l07pyrpnqfk9jz09kkh755zx5"))

(define rust-objc2-core-data-0.2.2
  (crate-source "objc2-core-data" "0.2.2"
                "1vvk8zjylfjjj04dzawydmqqz5ajvdkhf22cnb07ihbiw14vyzv1"))

(define rust-objc2-core-foundation-0.3.2
  (crate-source "objc2-core-foundation" "0.3.2"
                "0dnmg7606n4zifyjw4ff554xvjmi256cs8fpgpdmr91gckc0s61a"))

(define rust-objc2-core-image-0.2.2
  (crate-source "objc2-core-image" "0.2.2"
                "102csfb82zi2sbzliwsfd589ckz0gysf7y6434c9zj97lmihj9jm"))

(define rust-objc2-core-location-0.2.2
  (crate-source "objc2-core-location" "0.2.2"
                "10apgsrigqryvi4rcc0f6yfjflvrl83f4bi5hkr48ck89vizw300"))

(define rust-objc2-encode-4.1.0
  (crate-source "objc2-encode" "4.1.0"
                "0cqckp4cpf68mxyc2zgnazj8klv0z395nsgbafa61cjgsyyan9gg"))

(define rust-objc2-foundation-0.2.2
  (crate-source "objc2-foundation" "0.2.2"
                "1a6mi77jsig7950vmx9ydvsxaighzdiglk5d229k569pvajkirhf"))

(define rust-objc2-foundation-0.3.2
  (crate-source "objc2-foundation" "0.3.2"
                "0wijkxzzvw2xkzssds3fj8279cbykz2rz9agxf6qh7y2agpsvq73"))

(define rust-objc2-io-kit-0.3.2
  (crate-source "objc2-io-kit" "0.3.2"
                "05dvfcf97w39daaj5qsbfc399lw9hbx3s4h9nwgxrmlpjnizpyik"))

(define rust-objc2-link-presentation-0.2.2
  (crate-source "objc2-link-presentation" "0.2.2"
                "160k4qh00yrx57dabn3hzas4r98kmk9bc0qsy1jvwday3irax8d1"))

(define rust-objc2-metal-0.2.2
  (crate-source "objc2-metal" "0.2.2"
                "1mmdga66qpxrcfq3gxxhysfx3zg1hpx4z886liv3j0pnfq9bl36x"))

(define rust-objc2-quartz-core-0.2.2
  (crate-source "objc2-quartz-core" "0.2.2"
                "0ynw8819c36l11rim8n0yzk0fskbzrgaqayscyqi8swhzxxywaz4"))

(define rust-objc2-symbols-0.2.2
  (crate-source "objc2-symbols" "0.2.2"
                "1p04hjkxan18g2b7h9n2n8xxsvazapv2h6mfmmdk06zc7pz4ws0a"))

(define rust-objc2-ui-kit-0.2.2
  (crate-source "objc2-ui-kit" "0.2.2"
                "0vrb5r8z658l8c19bx78qks8c5hg956544yirf8npk90idwldfxq"))

(define rust-objc2-uniform-type-identifiers-0.2.2
  (crate-source "objc2-uniform-type-identifiers" "0.2.2"
                "1ziv4wkbxcaw015ypg0q49ycl7m14l3x56mpq2k1rznv92bmzyj4"))

(define rust-objc2-user-notifications-0.2.2
  (crate-source "objc2-user-notifications" "0.2.2"
                "1cscv2w3vxzaslz101ddv0z9ycrrs4ayikk4my4qd3im8bvcpkvn"))

(define rust-once-cell-1.21.4
  (crate-source "once_cell" "1.21.4"
                "0l1v676wf71kjg2khch4dphwh1jp3291ffiymr2mvy1kxd5kwz4z"))

(define rust-once-cell-polyfill-1.70.2
  (crate-source "once_cell_polyfill" "1.70.2"
                "1zmla628f0sk3fhjdjqzgxhalr2xrfna958s632z65bjsfv8ljrq"))

(define rust-opaque-debug-0.3.1
  (crate-source "opaque-debug" "0.3.1"
                "10b3w0kydz5jf1ydyli5nv10gdfp97xh79bgz327d273bs46b3f0"))

(define rust-option-ext-0.2.0
  (crate-source "option-ext" "0.2.0"
                "0zbf7cx8ib99frnlanpyikm1bx8qn8x602sw1n7bg6p9x94lyx04"))

(define rust-orbclient-0.3.51
  (crate-source "orbclient" "0.3.51"
                "1mmbx63ycb1n2c1nz8jmmnv3466kj3aj38wnpjhwzvbq6nrx7bjr"))

(define rust-ordered-float-5.3.0
  (crate-source "ordered-float" "5.3.0"
                "03mx5yg3ncp0g524y7zbyvhwcxpd8l9v30lgybm5bhqx2v551ndp"))

(define rust-ordered-stream-0.2.0
  (crate-source "ordered-stream" "0.2.0"
                "0l0xxp697q7wiix1gnfn66xsss7fdhfivl2k7bvpjs4i3lgb18ls"))

(define rust-os-str-bytes-6.6.1
  (crate-source "os_str_bytes" "6.6.1"
                "1885z1x4sm86v5p41ggrl49m58rbzzhd1kj72x46yy53p62msdg2"))

(define rust-owo-colors-3.5.0
  (crate-source "owo-colors" "3.5.0"
                "0vyvry6ba1xmpd45hpi6savd8mbx09jpmvnnwkf6z62pk6s4zc61"))

(define rust-pango-0.21.5
  (crate-source "pango" "0.21.5"
                "0sgb6xls3l07f7b257rp3gjx9g6mhckhgz5pbc37l1vq41gdilaj"))

(define rust-pango-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pango-sys" "0.21.5"
                "1zbcw3b2i5ixzy0ds65z2xdvllifzh8m5xid7lqgzmbfsckndw5l"))

(define rust-pangocairo-0.21.5
  (crate-source "pangocairo" "0.21.5"
                "1j589pc743ndih5y45bjdyyx75x7layxk585hsfr6wj06225qv5k"))

(define rust-pangocairo-sys-0.21.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pangocairo-sys" "0.21.5"
                "01llh57z386p059b113v3lkfzygkl05x8ag36w6nxrwbscdb1nza"))

(define rust-parking-2.2.1
  (crate-source "parking" "2.2.1"
                "1fnfgmzkfpjd69v4j9x737b1k8pnn054bvzcn5dm3pkgq595d3gk"))

(define rust-paste-1.0.15
  (crate-source "paste" "1.0.15"
                "02pxffpdqkapy292harq6asfjvadgp1s005fip9ljfsn9fvxgh2p"))

(define rust-percent-encoding-2.3.2
  (crate-source "percent-encoding" "2.3.2"
                "083jv1ai930azvawz2khv7w73xh8mnylk7i578cifndjn5y64kwv"))

(define rust-phf-0.13.1
  (crate-source "phf" "0.13.1"
                "1pzswx5gdglgjgp4azyzwyr4gh031r0kcnpqq6jblga72z3jsmn1"))

(define rust-phf-generator-0.13.1
  (crate-source "phf_generator" "0.13.1"
                "0dwpp11l41dy9mag4phkyyvhpf66lwbp79q3ik44wmhyfqxcwnhk"))

(define rust-phf-macros-0.13.1
  (crate-source "phf_macros" "0.13.1"
                "1vv9h8pr7xh18sigpvq1hxc8q9nmjmv6gdpqsp65krxiahmh6bw1"))

(define rust-phf-shared-0.13.1
  (crate-source "phf_shared" "0.13.1"
                "0rpjchnswm0x5l4mz9xqfpw0j4w68sjvyqrdrv13h7lqqmmyyzz5"))

(define rust-pin-project-1.1.11
  (crate-source "pin-project" "1.1.11"
                "05zm3y3bl83ypsr6favxvny2kys4i19jiz1y18ylrbxwsiz9qx7i"))

(define rust-pin-project-internal-1.1.11
  (crate-source "pin-project-internal" "1.1.11"
                "1ik4mpb92da75inmjvxf2qm61vrnwml3x24wddvrjlqh1z9hxcnr"))

(define rust-pin-project-lite-0.2.17
  (crate-source "pin-project-lite" "0.2.17"
                "1kfmwvs271si96zay4mm8887v5khw0c27jc9srw1a75ykvgj54x8"))

(define rust-piper-0.2.5
  (crate-source "piper" "0.2.5"
                "1hd3j94mw5dwc457gs9ssb2r5b9iipywndf5srqx7pj38jd4fdf8"))

(define rust-pipewire-0.9.2
  (crate-source "pipewire" "0.9.2"
                "0i4ddb89cr8x02zqy35krlx5mgkd3mqr0qbwkx4mdmqipydbi24n"))

(define rust-pipewire-sys-0.9.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pipewire-sys" "0.9.2"
                "0dpa8q10b9cja5z5r5zgb8q27pnpla7kn3h91c11gjnnw3z8l0nb"))

(define rust-pixman-0.2.1
  (crate-source "pixman" "0.2.1"
                "1pqybqb7rmd58yr9xvmd8iix30znw5w71cq2wnlc16n1jva1g8nf"))

(define rust-pixman-sys-0.1.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pixman-sys" "0.1.0"
                "1nja8kc7zs1w4lhllvsgssa0b07n4cgwb0zyvqapj7g8i4z4i851"))

(define rust-pkg-config-0.3.32
  (crate-source "pkg-config" "0.3.32"
                "0k4h3gnzs94sjb2ix6jyksacs52cf1fanpwsmlhjnwrdnp8dppby"))

(define rust-pkg-config-0.3.33
  (crate-source "pkg-config" "0.3.33"
                "17jnqmcbxsnwhg9gjf0nh6dj5k0x3hgwi3mb9krjnmfa9v435w8r"))

(define rust-plain-0.2.3
  (crate-source "plain" "0.2.3"
                "19n1xbxb4wa7w891268bzf6cbwq4qvdb86bik1z129qb0xnnnndl"))

(define rust-png-0.18.1
  (crate-source "png" "0.18.1"
                "0qca282xp8a6d7mikxrwji3f52mjn4vnqxz2v9iz5adj665rnxk0"))

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

(define rust-pretty-assertions-1.4.1
  (crate-source "pretty_assertions" "1.4.1"
                "0v8iq35ca4rw3rza5is3wjxwsf88303ivys07anc5yviybi31q9s"))

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

(define rust-profiling-1.0.17
  (crate-source "profiling" "1.0.17"
                "0wqp6i1bl7azy9270dp92srbbr55mgdh9qnk5b1y44lyarmlif1y"))

(define rust-profiling-procmacros-1.0.17
  (crate-source "profiling-procmacros" "1.0.17"
                "0nrxdh5r723raxbs136jmjx46p0c5qgai8jwz4j555mn0ad7ywaj"))

(define rust-proptest-1.11.0
  (crate-source "proptest" "1.11.0"
                "0i27rr5drw4ic8hjzx6i1c6q8s7kmsgpfmzy4m80ys2c6k1gqiab"))

(define rust-proptest-derive-0.8.0
  (crate-source "proptest-derive" "0.8.0"
                "16sl8waqx20flr49aj24dh4rfbzqkcpzj6rfm7xxmpb432l28yf5"))

(define rust-quick-error-1.2.3
  (crate-source "quick-error" "1.2.3"
                "1q6za3v78hsspisc197bg3g7rpc989qycy8ypr8ap8igv10ikl51"))

(define rust-quick-xml-0.37.5
  (crate-source "quick-xml" "0.37.5"
                "1yxpd7rc2qn6f4agfj47ps2z89vv7lvzxpzawqirix8bmyhrf7ik"))

(define rust-quick-xml-0.38.4
  (crate-source "quick-xml" "0.38.4"
                "0772siy4d9vlq77842012c8cycs3y0szxkv62rh9sh2sqmc20v5n"))

(define rust-quick-xml-0.39.2
  (crate-source "quick-xml" "0.39.2"
                "0z86jkw618p0d7q3zqp7pzh7cnf7wwlanzx8gyma3dffwzl233wm"))

(define rust-quote-0.3.15
  (crate-source "quote" "0.3.15"
                "0yhnnix4dzsv8y4wwz4csbnqjfh73al33j35msr10py6cl5r4vks"))

(define rust-quote-1.0.45
  (crate-source "quote" "1.0.45"
                "095rb5rg7pbnwdp6v8w5jw93wndwyijgci1b5lw8j1h5cscn3wj1"))

(define rust-r-efi-5.3.0
  (crate-source "r-efi" "5.3.0"
                "03sbfm3g7myvzyylff6qaxk4z6fy76yv860yy66jiswc2m6b7kb9"))

(define rust-r-efi-6.0.0
  (crate-source "r-efi" "6.0.0"
                "1gyrl2k5fyzj9k7kchg2n296z5881lg7070msabid09asp3wkp7q"))

(define rust-rand-0.8.5
  (crate-source "rand" "0.8.5"
                "013l6931nn7gkc23jz5mm3qdhf93jjf0fg64nz2lp4i51qd8vbrl"))

(define rust-rand-0.9.4
  (crate-source "rand" "0.9.4"
                "1sknbxgs6nfg0nxdd7689lwbyr2i4vaswchrv4b34z8vpc3azia4"))

(define rust-rand-chacha-0.3.1
  (crate-source "rand_chacha" "0.3.1"
                "123x2adin558xbhvqb8w4f6syjsdkmqff8cxwhmjacpsl1ihmhg6"))

(define rust-rand-chacha-0.9.0
  (crate-source "rand_chacha" "0.9.0"
                "1jr5ygix7r60pz0s1cv3ms1f6pd1i9pcdmnxzzhjc3zn3mgjn0nk"))

(define rust-rand-core-0.6.4
  (crate-source "rand_core" "0.6.4"
                "0b4j2v4cb5krak1pv6kakv4sz6xcwbrmy2zckc32hsigbrwy82zc"))

(define rust-rand-core-0.9.5
  (crate-source "rand_core" "0.9.5"
                "0g6qc5r3f0hdmz9b11nripyp9qqrzb0xqk9piip8w8qlvqkcibvn"))

(define rust-rand-xorshift-0.4.0
  (crate-source "rand_xorshift" "0.4.0"
                "0njsn25pis742gb6b89cpq7jp48v9n23a9fvks10yczwks8n4fai"))

(define rust-raw-window-handle-0.6.2
  (crate-source "raw-window-handle" "0.6.2"
                "0ff5c648hncwx7hm2a8fqgqlbvbl4xawb6v3xxv9wkpjyrr5arr0"))

(define rust-rayon-1.12.0
  (crate-source "rayon" "1.12.0"
                "0vcj63xgnk72c30vdrak7dhl53snnaqv9x2faf1d94hzg1kb2fgv"))

(define rust-rayon-core-1.13.0
  (crate-source "rayon-core" "1.13.0"
                "14dbr0sq83a6lf1rfjq5xdpk5r6zgzvmzs5j6110vlv2007qpq92"))

(define rust-redox-syscall-0.4.1
  (crate-source "redox_syscall" "0.4.1"
                "1aiifyz5dnybfvkk4cdab9p2kmphag1yad6iknc7aszlxxldf8j7"))

(define rust-redox-syscall-0.7.4
  (crate-source "redox_syscall" "0.7.4"
                "0fk4infcfn2hvshrwgf7r48rf9mr1zxy1a28d7xn798x7ffasl7l"))

(define rust-redox-users-0.4.6
  (crate-source "redox_users" "0.4.6"
                "0hya2cxx6hxmjfxzv9n8rjl5igpychav7zfi1f81pz6i4krry05s"))

(define rust-redox-users-0.5.2
  (crate-source "redox_users" "0.5.2"
                "1b17q7gf7w8b1vvl53bxna24xl983yn7bd00gfbii74bcg30irm4"))

(define rust-ref-cast-1.0.25
  (crate-source "ref-cast" "1.0.25"
                "0zdzc34qjva9xxgs889z5iz787g81hznk12zbk4g2xkgwq530m7k"))

(define rust-ref-cast-impl-1.0.25
  (crate-source "ref-cast-impl" "1.0.25"
                "1nkhn1fklmn342z5c4mzfzlxddv3x8yhxwwk02cj06djvh36065p"))

(define rust-regex-1.12.3
  (crate-source "regex" "1.12.3"
                "0xp2q0x7ybmpa5zlgaz00p8zswcirj9h8nry3rxxsdwi9fhm81z1"))

(define rust-regex-automata-0.4.14
  (crate-source "regex-automata" "0.4.14"
                "13xf7hhn4qmgfh784llcp2kzrvljd13lb2b1ca0mwnf15w9d87bf"))

(define rust-regex-syntax-0.8.10
  (crate-source "regex-syntax" "0.8.10"
                "02jx311ka0daxxc7v45ikzhcl3iydjbbb0mdrpc1xgg8v7c7v2fw"))

(define rust-rusb-0.8.1
  (crate-source "rusb" "0.8.1"
                "1b80icrc7amkg1mz1cwi4hprslfcw1g3w2vm3ixyfnyc5130i9fr"))

(define rust-rustc-hash-2.1.2
  (crate-source "rustc-hash" "2.1.2"
                "1gjdc5bw9982cj176jvgz9rrqf9xvr1q1ddpzywf5qhs7yzhlc4l"))

(define rust-rustc-version-0.4.1
  (crate-source "rustc_version" "0.4.1"
                "14lvdsmr5si5qbqzrajgb6vfn69k0sfygrvfvr2mps26xwi3mjyg"))

(define rust-rustix-0.38.44
  (crate-source "rustix" "0.38.44"
                "0m61v0h15lf5rrnbjhcb9306bgqrhskrqv7i1n0939dsw8dbrdgx"))

(define rust-rustix-1.1.4
  (crate-source "rustix" "1.1.4"
                "14511f9yjqh0ix07xjrjpllah3325774gfwi9zpq72sip5jlbzmn"))

(define rust-rustversion-1.0.22
  (crate-source "rustversion" "1.0.22"
                "0vfl70jhv72scd9rfqgr2n11m5i9l1acnk684m2w83w0zbqdx75k"))

(define rust-rusty-fork-0.3.1
  (crate-source "rusty-fork" "0.3.1"
                "1qkf9rvz2irb1wlbkrhrns8n9hnax48z1lgql5nqyr2fyagzfsyc"))

(define rust-salsa20-0.10.2
  (crate-source "salsa20" "0.10.2"
                "04w211x17xzny53f83p8f7cj7k2hi8zck282q5aajwqzydd2z8lp"))

(define rust-same-file-1.0.6
  (crate-source "same-file" "1.0.6"
                "00h5j1w87dmhnvbv9l8bic3y7xxsnjmssvifw2ayvgx9mb1ivz4k"))

(define rust-schemars-1.2.1
  (crate-source "schemars" "1.2.1"
                "1k16qzpdpy6p9hrh18q2l6cwawxzyqi25f8masa13l0wm8v2zd52"))

(define rust-schemars-derive-1.2.1
  (crate-source "schemars_derive" "1.2.1"
                "0zrh1ckcc63sqy5hyhnh2lbxh4vmbij2z4f1g5za1vmayi85n4bx"))

(define rust-scoped-tls-1.0.1
  (crate-source "scoped-tls" "1.0.1"
                "15524h04mafihcvfpgxd8f4bgc3k95aclz8grjkg9a0rxcvn9kz1"))

(define rust-sd-notify-0.5.0
  (crate-source "sd-notify" "0.5.0"
                "0xpy528vqfasq389pwg9z86w0m0bfsfhz8r7vpqzljv9kqszfkiy"))

(define rust-semver-1.0.27
  (crate-source "semver" "1.0.27"
                "1qmi3akfrnqc2hfkdgcxhld5bv961wbk8my3ascv5068mc5fnryp"))

(define rust-semver-1.0.28
  (crate-source "semver" "1.0.28"
                "1kaimrpy876bcgi8bfj0qqfxk77zm9iz2zhn1hp9hj685z854y4a"))

(define rust-serde-1.0.228
  (crate-source "serde" "1.0.228"
                "17mf4hhjxv5m90g42wmlbc61hdhlm6j9hwfkpcnd72rpgzm993ls"))

(define rust-serde-core-1.0.228
  (crate-source "serde_core" "1.0.228"
                "1bb7id2xwx8izq50098s5j2sqrrvk31jbbrjqygyan6ask3qbls1"))

(define rust-serde-derive-1.0.228
  (crate-source "serde_derive" "1.0.228"
                "0y8xm7fvmr2kjcd029g9fijpndh8csv5m20g4bd76w8qschg4h6m"))

(define rust-serde-derive-internals-0.29.1
  (crate-source "serde_derive_internals" "0.29.1"
                "04g7macx819vbnxhi52cx0nhxi56xlhrybgwybyy7fb9m4h6mlhq"))

(define rust-serde-json-1.0.149
  (crate-source "serde_json" "1.0.149"
                "11jdx4vilzrjjd1dpgy67x5lgzr0laplz30dhv75lnf5ffa07z43"))

(define rust-serde-repr-0.1.20
  (crate-source "serde_repr" "0.1.20"
                "1755gss3f6lwvv23pk7fhnjdkjw7609rcgjlr8vjg6791blf6php"))

(define rust-serde-spanned-1.1.1
  (crate-source "serde_spanned" "1.1.1"
                "09jzk7i6wihn3d8i3wi4j4n98ghi93c3b8m8k64nxq0ijn3vaqk6"))

(define rust-sha-1-0.9.8
  (crate-source "sha-1" "0.9.8"
                "19jibp8l9k5v4dnhj5kfhaczdfd997h22qz0hin6pw9wvc9ngkcr"))

(define rust-sha-1-0.10.1
  (crate-source "sha-1" "0.10.1"
                "1700fs5aiiailpd5h0ax4sgs2ngys0mqf3p4j0ry6j2p2zd8l1gm"))

(define rust-sha2-0.10.9
  (crate-source "sha2" "0.10.9"
                "10xjj843v31ghsksd9sl9y12qfc48157j1xpb8v1ml39jy0psl57"))

(define rust-sharded-slab-0.1.7
  (crate-source "sharded-slab" "0.1.7"
                "1xipjr4nqsgw34k7a2cgj9zaasl2ds6jwn89886kww93d32a637l"))

(define rust-shlex-1.3.0
  (crate-source "shlex" "1.3.0"
                "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))

(define rust-signal-hook-registry-1.4.8
  (crate-source "signal-hook-registry" "1.4.8"
                "06vc7pmnki6lmxar3z31gkyg9cw7py5x9g7px70gy2hil75nkny4"))

(define rust-simd-adler32-0.3.9
  (crate-source "simd-adler32" "0.3.9"
                "0532ysdwcvzyp2bwpk8qz0hijplcdwpssr5gy5r7qwqqy5z5qgbh"))

(define rust-simd-cesu8-1.1.1
  (crate-source "simd_cesu8" "1.1.1"
                "0crcbgvyycmazji2vqj9vxn2czdyl3gxmicp4xqdzkc7pdbh3ycl"))

(define rust-simdutf8-0.1.5
  (crate-source "simdutf8" "0.1.5"
                "0vmpf7xaa0dnaikib5jlx6y4dxd3hxqz6l830qb079g7wcsgxag3"))

(define rust-similar-2.7.0
  (crate-source "similar" "2.7.0"
                "1aidids7ymfr96s70232s6962v5g9l4zwhkvcjp4c5hlb6b5vfxv"))

(define rust-siphasher-1.0.2
  (crate-source "siphasher" "1.0.2"
                "13k7cfbpcm8qgj9p2n8dwg9skv9s0hxk5my30j5chy1p4l78bamj"))

(define rust-slab-0.4.12
  (crate-source "slab" "0.4.12"
                "1xcwik6s6zbd3lf51kkrcicdq2j4c1fw0yjdai2apy9467i0sy8c"))

(define rust-slog-2.8.2
  (crate-source "slog" "2.8.2"
                "1hcmd6fzkxqqjy6sv31cbw6gqdzq93njcr06zjyx48hvd5jqafwv"))

(define rust-slog-term-2.9.2
  (crate-source "slog-term" "2.9.2"
                "1d891y1lr41l1af4xalnikdq2b4xq1qkhay0skxddviq1dlgrcaw"))

(define rust-smallvec-1.15.1
  (crate-source "smallvec" "1.15.1"
                "00xxdxxpgyq5vjnpljvkmy99xij5rxgh913ii1v16kzynnivgcb7"))

(define rust-smawk-0.3.2
  (crate-source "smawk" "0.3.2"
                "0344z1la39incggwn6nl45k8cbw2x10mr5j0qz85cdz9np0qihxp"))

(define rust-smithay-0.7.0.ff5fa7d
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/Smithay/smithay.git")
          (commit "ff5fa7df392cecfba049ffed55cdaa4e98a8e7ef")))
    (file-name (git-file-name "rust-smithay" "0.7.0.ff5fa7d"))
    (sha256 (base32 "1dfksva7hizx675vh128ibrbf6ggjh2a01jm41qgb0dgyi6wcpsd"))))

(define rust-smithay-client-toolkit-0.19.2
  (crate-source "smithay-client-toolkit" "0.19.2"
                "05h05hg4dn3v6br5jbdbs5nalk076a64s7fn6i01nqzby2hxwmrl"))

(define rust-smithay-drm-extras-0.1.0.ff5fa7d
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/Smithay/smithay.git")
          (commit "ff5fa7df392cecfba049ffed55cdaa4e98a8e7ef")))
    (file-name (git-file-name "rust-smithay-drm-extras" "0.1.0.ff5fa7d"))
    (sha256 (base32 "1dfksva7hizx675vh128ibrbf6ggjh2a01jm41qgb0dgyi6wcpsd"))))

(define rust-smol-str-0.2.2
  (crate-source "smol_str" "0.2.2"
                "1bfylqf2vnqaglw58930vpxm2rfzji5gjp15a2c0kh8aj6v8ylyx"))

(define rust-static-assertions-1.1.0
  (crate-source "static_assertions" "1.1.0"
                "0gsl6xmw10gvn3zs1rv99laj5ig7ylffnh71f9l34js4nr4r7sx2"))

(define rust-strsim-0.10.0
  (crate-source "strsim" "0.10.0"
                "08s69r4rcrahwnickvi0kq49z524ci50capybln83mg6b473qivk"))

(define rust-strsim-0.11.1
  (crate-source "strsim" "0.11.1"
                "0kzvqlw8hxqb7y598w1s0hxlnmi84sg5vsipp3yg5na5d1rvba3x"))

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

(define rust-supports-color-2.1.0
  (crate-source "supports-color" "2.1.0"
                "12csf7chawxinaapm9rh718nha9hggk6ra86fdaw9hxdagg8qffn"))

(define rust-supports-hyperlinks-2.1.0
  (crate-source "supports-hyperlinks" "2.1.0"
                "0g93nh1db3f9lyd0ry35bqjrxkg6sbysn36x9hgd9m5h5rlk2hpq"))

(define rust-supports-unicode-2.1.0
  (crate-source "supports-unicode" "2.1.0"
                "0yp703pvpzpmaw9mpncvwf0iqis4xmhs569ii1g20jhqvngc2l7q"))

(define rust-syn-1.0.109
  (crate-source "syn" "1.0.109"
                "0ds2if4600bd59wsv7jjgfkayfzy3hnazs394kz6zdkmna8l3dkj"))

(define rust-syn-2.0.117
  (crate-source "syn" "2.0.117"
                "16cv7c0wbn8amxc54n4w15kxlx5ypdmla8s0gxr2l7bv7s0bhrg6"))

(define rust-sysinfo-0.38.4
  (crate-source "sysinfo" "0.38.4"
                "0bx5wjp16cyckr9c0fxzrfcx54g4aa15f1k47kmqsl7yicpnmawj"))

(define rust-system-deps-7.0.8
  (crate-source "system-deps" "7.0.8"
                "1rwnfw9dm6ck65a7lfjfpn2c91gwj88brz2i09z3fdbknvz3asir"))

(define rust-tabwriter-1.4.1
  (crate-source "tabwriter" "1.4.1"
                "0ch4823i90iw35an0g000f3ii8cs8dkv5gnbddzgyzf81qpizsgw"))

(define rust-target-lexicon-0.13.3
  (crate-source "target-lexicon" "0.13.3"
                "0355pbycq0cj29h1rp176l57qnfwmygv7hwzchs7iq15gibn4zyz"))

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

(define rust-terminal-size-0.1.17
  (crate-source "terminal_size" "0.1.17"
                "1pq60ng1a7fjp597ifk1cqlz8fv9raz9xihddld1m1pfdia1lg33"))

(define rust-termtree-0.5.1
  (crate-source "termtree" "0.5.1"
                "10s610ax6nb70yi7xfmwcb6d3wi9sj5isd0m63gy2pizr2zgwl4g"))

(define rust-textwrap-0.15.2
  (crate-source "textwrap" "0.15.2"
                "0galmidi6gpn308b1kv3r4qbb48j2926lcj0idwhdhlylhjybcxp"))

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

(define rust-toml-1.1.2+spec-1.1.0
  (crate-source "toml" "1.1.2+spec-1.1.0"
                "1vpggpamqhw4852kic7465zsidczsla06wz6friqkkfbhigd3ww1"))

(define rust-toml-datetime-1.0.1+spec-1.1.0
  (crate-source "toml_datetime" "1.0.1+spec-1.1.0"
                "1sgk7zc6x187iib7kj1nzn44mp0zrk9hgii69rbar35m3ms0wclv"))

(define rust-toml-datetime-1.1.1+spec-1.1.0
  (crate-source "toml_datetime" "1.1.1+spec-1.1.0"
                "1mws2mkkf46l7inn77azhm0vdwxngv9vsbhbl0ah33p2c9gzcr9i"))

(define rust-toml-edit-0.25.11+spec-1.1.0
  (crate-source "toml_edit" "0.25.11+spec-1.1.0"
                "0awzffbkx33v9x4h19b5mfrwp3sn4ifr16y58sbk6j6l5v9c8n8b"))

(define rust-toml-edit-0.25.5+spec-1.1.0
  (crate-source "toml_edit" "0.25.5+spec-1.1.0"
                "1qgjkq687jkdrc3wq4fi95lj6d0bvwqs9xi3d41wx2x28h3a98cc"))

(define rust-toml-parser-1.0.10+spec-1.1.0
  (crate-source "toml_parser" "1.0.10+spec-1.1.0"
                "081lsv63zphnff9ssb0yjavcc82sblvj808rvwb4h76kxx5mpwkx"))

(define rust-toml-parser-1.1.2+spec-1.1.0
  (crate-source "toml_parser" "1.1.2+spec-1.1.0"
                "09kmzc55a0j21whm290wlf5a8b18a0qc87a1s8sncrckc6wfkax2"))

(define rust-toml-writer-1.1.1+spec-1.1.0
  (crate-source "toml_writer" "1.1.1+spec-1.1.0"
                "1nwjhvvrxz8f4ck1qi4xcz2x9qhpci37nrknhxxf9sqk22dsyvbm"))

(define rust-tracing-0.1.44
  (crate-source "tracing" "0.1.44"
                "006ilqkg1lmfdh3xhg3z762izfwmxcvz0w7m4qx2qajbz9i1drv3"))

(define rust-tracing-attributes-0.1.31
  (crate-source "tracing-attributes" "0.1.31"
                "1np8d77shfvz0n7camx2bsf1qw0zg331lra0hxb4cdwnxjjwz43l"))

(define rust-tracing-core-0.1.36
  (crate-source "tracing-core" "0.1.36"
                "16mpbz6p8vd6j7sf925k9k8wzvm9vdfsjbynbmaxxyq6v7wwm5yv"))

(define rust-tracing-log-0.2.0
  (crate-source "tracing-log" "0.2.0"
                "1hs77z026k730ij1a9dhahzrl0s073gfa2hm5p0fbl0b80gmz1gf"))

(define rust-tracing-subscriber-0.3.23
  (crate-source "tracing-subscriber" "0.3.23"
                "06fkr0qhggvrs861d7f74pn3i3a10h5jsp4n70jj9ys5b675fzyb"))

(define rust-tracy-client-0.18.4
  (crate-source "tracy-client" "0.18.4"
                "19g6g3s5x891k419ahl6y4xnbz100viyjwn7j2mqcpdcmqxzrxm4"))

(define rust-tracy-client-sys-0.28.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "tracy-client-sys" "0.28.0"
                "1gxc1lb3yvbzb8n5069x1gis6vpfdly7n5bj7n8iq37j919wkxy5"))

(define rust-typenum-1.19.0
  (crate-source "typenum" "1.19.0"
                "1fw2mpbn2vmqan56j1b3fbpcdg80mz26fm53fs16bq5xcq84hban"))

(define rust-udev-0.9.3
  (crate-source "udev" "0.9.3"
                "17vy1yc6ipb5m2kc2d4lx2qpj45yr7grsjzm3y2gq0a4xblkfkmg"))

(define rust-uds-windows-1.2.1
  (crate-source "uds_windows" "1.2.1"
                "0vidqwwfgn8wyzvbxiqil787b4wyqjia50zpdbbjqx7n8wlgpxpj"))

(define rust-unarray-0.1.4
  (crate-source "unarray" "0.1.4"
                "154smf048k84prsdgh09nkm2n0w0336v84jd4zikyn6v6jrqbspa"))

(define rust-uncased-0.9.10
  (crate-source "uncased" "0.9.10"
                "15q6r6g4fszr8c2lzg9z9k9g52h8g29h24awda3d72cyw37qzf71"))

(define rust-unicode-ident-1.0.24
  (crate-source "unicode-ident" "1.0.24"
                "0xfs8y1g7syl2iykji8zk5hgfi5jw819f5zsrbaxmlzwsly33r76"))

(define rust-unicode-linebreak-0.1.5
  (crate-source "unicode-linebreak" "0.1.5"
                "07spj2hh3daajg335m4wdav6nfkl0f6c0q72lc37blr97hych29v"))

(define rust-unicode-segmentation-1.13.2
  (crate-source "unicode-segmentation" "1.13.2"
                "135a26m4a0wj319gcw28j6a5aqvz00jmgwgmcs6szgxjf942facn"))

(define rust-unicode-width-0.1.14
  (crate-source "unicode-width" "0.1.14"
                "1bzn2zv0gp8xxbxbhifw778a7fc93pa6a1kj24jgg9msj07f7mkx"))

(define rust-unicode-width-0.2.2
  (crate-source "unicode-width" "0.2.2"
                "0m7jjzlcccw716dy9423xxh0clys8pfpllc5smvfxrzdf66h9b5l"))

(define rust-unicode-xid-0.2.6
  (crate-source "unicode-xid" "0.2.6"
                "0lzqaky89fq0bcrh6jj6bhlz37scfd8c7dsj5dq7y32if56c1hgb"))

(define rust-universal-hash-0.5.1
  (crate-source "universal-hash" "0.5.1"
                "1sh79x677zkncasa95wz05b36134822w6qxmi1ck05fwi33f47gw"))

(define rust-utf8parse-0.2.2
  (crate-source "utf8parse" "0.2.2"
                "088807qwjq46azicqwbhlmzwrbkz7l4hpw43sdkdyyk524vdxaq6"))

(define rust-uuid-1.22.0
  (crate-source "uuid" "1.22.0"
                "0dvsfn44sddhyhlhk7m3i559wyb125h86799fm5abky0067kr3d6"))

(define rust-uuid-1.23.1
  (crate-source "uuid" "1.23.1"
                "0xlwg23rmsfl3gx98qsyzpl24pf4bs9wi3mqx5c6i319hyb4mmyx"))

(define rust-valuable-0.1.1
  (crate-source "valuable" "0.1.1"
                "0r9srp55v7g27s5bg7a2m095fzckrcdca5maih6dy9bay6fflwxs"))

(define rust-vcpkg-0.2.15
  (crate-source "vcpkg" "0.2.15"
                "09i4nf5y8lig6xgj3f7fyrvzd3nlaw4znrihw8psidvv5yk4xkdc"))

(define rust-version-check-0.9.5
  (crate-source "version_check" "0.9.5"
                "0nhhi4i5x89gm911azqbn7avs9mdacw2i3vcz3cnmz3mv4rqz4hb"))

(define rust-version-compare-0.2.1
  (crate-source "version-compare" "0.2.1"
                "03nziqxwnxlizl42cwsx33vi5xd2cf2jnszhh9rzay7g6xl8bhh3"))

(define rust-wait-timeout-0.2.1
  (crate-source "wait-timeout" "0.2.1"
                "04azqv9mnfxgvnc8j2wp362xraybakh2dy1nj22gj51rdl93pb09"))

(define rust-walkdir-2.5.0
  (crate-source "walkdir" "2.5.0"
                "0jsy7a710qv8gld5957ybrnc07gavppp963gs32xk4ag8130jy99"))

(define rust-wasi-0.11.1+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.1+wasi-snapshot-preview1"
                "0jx49r7nbkbhyfrfyhz0bm4817yrnxgd3jiwwwfv0zl439jyrwyc"))

(define rust-wasip2-1.0.1+wasi-0.2.4
  (crate-source "wasip2" "1.0.1+wasi-0.2.4"
                "1rsqmpspwy0zja82xx7kbkbg9fv34a4a2if3sbd76dy64a244qh5"))

(define rust-wasip2-1.0.2+wasi-0.2.9
  (crate-source "wasip2" "1.0.2+wasi-0.2.9"
                "1xdw7v08jpfjdg94sp4lbdgzwa587m5ifpz6fpdnkh02kwizj5wm"))

(define rust-wasip3-0.4.0+wasi-0.3.0-rc-2026-01-06
  (crate-source "wasip3" "0.4.0+wasi-0.3.0-rc-2026-01-06"
                "19dc8p0y2mfrvgk3qw3c3240nfbylv22mvyxz84dqpgai2zzha2l"))

(define rust-wasm-bindgen-0.2.114
  (crate-source "wasm-bindgen" "0.2.114"
                "13nkhw552hpllrrmkd2x9y4bmcxr82kdpky2n667kqzcq6jzjck5"))

(define rust-wasm-bindgen-0.2.118
  (crate-source "wasm-bindgen" "0.2.118"
                "129s5r14fx4v4xrzpx2c6l860nkxpl48j50y7kl6j16bpah3iy8b"))

(define rust-wasm-bindgen-futures-0.4.68
  (crate-source "wasm-bindgen-futures" "0.4.68"
                "1y7bq5d9fk7s9xaayx38bgs9ns35na0kpb5zw19944zvya1x6wgk"))

(define rust-wasm-bindgen-macro-0.2.114
  (crate-source "wasm-bindgen-macro" "0.2.114"
                "1rhq9kkl7n0zjrag9p25xsi4aabpgfkyf02zn4xv6pqhrw7xb8hq"))

(define rust-wasm-bindgen-macro-0.2.118
  (crate-source "wasm-bindgen-macro" "0.2.118"
                "1v98r8vs17cj8918qsg0xx4nlg4nxk1g0jd4nwnyrh1687w29zzf"))

(define rust-wasm-bindgen-macro-support-0.2.114
  (crate-source "wasm-bindgen-macro-support" "0.2.114"
                "1qriqqjpn922kv5c7f7627fj823k5aifv06j2gvwsiy5map4rkh3"))

(define rust-wasm-bindgen-macro-support-0.2.118
  (crate-source "wasm-bindgen-macro-support" "0.2.118"
                "0169jr0q469hfx5zqxfyywf2h2f4aj17vn4zly02nfwqmxghc24x"))

(define rust-wasm-bindgen-shared-0.2.114
  (crate-source "wasm-bindgen-shared" "0.2.114"
                "05lc6w64jxlk4wk8rjci4z61lhx2ams90la27a41gvi3qaw2d8vm"))

(define rust-wasm-bindgen-shared-0.2.118
  (crate-source "wasm-bindgen-shared" "0.2.118"
                "0ag1vvdzi4334jlzilsy14y3nyzwddf1ndn62fyhf6bg62g4vl2z"))

(define rust-wasm-encoder-0.244.0
  (crate-source "wasm-encoder" "0.244.0"
                "06c35kv4h42vk3k51xjz1x6hn3mqwfswycmr6ziky033zvr6a04r"))

(define rust-wasm-metadata-0.244.0
  (crate-source "wasm-metadata" "0.244.0"
                "02f9dhlnryd2l7zf03whlxai5sv26x4spfibjdvc3g9gd8z3a3mv"))

(define rust-wasmparser-0.244.0
  (crate-source "wasmparser" "0.244.0"
                "1zi821hrlsxfhn39nqpmgzc0wk7ax3dv6vrs5cw6kb0v5v3hgf27"))

(define rust-wayland-backend-0.3.15
  (crate-source "wayland-backend" "0.3.15"
                "0pbm8j3vv6baqz312biwqfi4qzadbi6nng9v4p3nx4afnlhdsmr8"))

(define rust-wayland-client-0.31.14
  (crate-source "wayland-client" "0.31.14"
                "0i014rcfjgccknnlyfk94fxn4w32l56cpjdmi4qhqsblpfb7qp34"))

(define rust-wayland-csd-frame-0.3.0
  (crate-source "wayland-csd-frame" "0.3.0"
                "0zjcmcqprfzx57hlm741n89ssp4sha5yh5cnmbk2agflvclm0p32"))

(define rust-wayland-cursor-0.31.14
  (crate-source "wayland-cursor" "0.31.14"
                "0kdk7xwj465idk54jf1f24024gdp63wyagca68a176xyh23x2lja"))

(define rust-wayland-egl-0.32.11
  (crate-source "wayland-egl" "0.32.11"
                "0lalq3dzd1x7j7v2dsf9zmwp1m6sy22gyf1gasvxjnwyqjvvv5wv"))

(define rust-wayland-protocols-0.32.12
  (crate-source "wayland-protocols" "0.32.12"
                "13rdk2akpdg90v42sjlz7c86541isxgq347772cl5qmd7i98afjn"))

(define rust-wayland-protocols-misc-0.3.12
  (crate-source "wayland-protocols-misc" "0.3.12"
                "1j19dg8h98s153rj2fvbqkghjicdfgjjkr6nvaw0jgpjkrcng5bf"))

(define rust-wayland-protocols-plasma-0.3.12
  (crate-source "wayland-protocols-plasma" "0.3.12"
                "14adi3xgkldbih60705gshlq2lskds5chhsn3znk271cxgqqqv9b"))

(define rust-wayland-protocols-wlr-0.3.12
  (crate-source "wayland-protocols-wlr" "0.3.12"
                "0d424vn2hj27r4gjlshm6hy8fcqysr805jkqdjbwgmrng0pya17b"))

(define rust-wayland-scanner-0.31.10
  (crate-source "wayland-scanner" "0.31.10"
                "0jjbsb04pzz8kqiw0wy2ssqx6dqpy70ixrm3ck1vsvnq1y8llclw"))

(define rust-wayland-server-0.31.13
  (crate-source "wayland-server" "0.31.13"
                "1800f2fg41p28q9ddhdv21b78aqahcm9w2aa9zh854f40kmlc66c"))

(define rust-wayland-sys-0.31.11
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "wayland-sys" "0.31.11"
                "1gp3hlkxx13i55lyyi794vnw9a780z3skx0xhj71zr69xwzv5snq"))

(define rust-web-sys-0.3.95
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.95"
                "0zfr2jy5bpkkggl88i43yy37p538hg20i56kwn421yj9g6qznbag"))

(define rust-web-time-1.1.0
  (crate-source "web-time" "1.1.0"
                "1fx05yqx83dhx628wb70fyy10yjfq1jpl20qfqhdkymi13rq0ras"))

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

(define rust-windows-aarch64-gnullvm-0.48.5
  (crate-source "windows_aarch64_gnullvm" "0.48.5"
                "1n05v7qblg1ci3i567inc7xrkmywczxrs1z3lj3rkkxw18py6f1b"))

(define rust-windows-aarch64-gnullvm-0.52.6
  (crate-source "windows_aarch64_gnullvm" "0.52.6"
                "1lrcq38cr2arvmz19v32qaggvj8bh1640mdm9c2fr877h0hn591j"))

(define rust-windows-aarch64-msvc-0.48.5
  (crate-source "windows_aarch64_msvc" "0.48.5"
                "1g5l4ry968p73g6bg6jgyvy9lb8fyhcs54067yzxpcpkf44k2dfw"))

(define rust-windows-aarch64-msvc-0.52.6
  (crate-source "windows_aarch64_msvc" "0.52.6"
                "0sfl0nysnz32yyfh773hpi49b1q700ah6y7sacmjbqjjn5xjmv09"))

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

(define rust-windows-i686-gnu-0.48.5
  (crate-source "windows_i686_gnu" "0.48.5"
                "0gklnglwd9ilqx7ac3cn8hbhkraqisd0n83jxzf9837nvvkiand7"))

(define rust-windows-i686-gnu-0.52.6
  (crate-source "windows_i686_gnu" "0.52.6"
                "02zspglbykh1jh9pi7gn8g1f97jh1rrccni9ivmrfbl0mgamm6wf"))

(define rust-windows-i686-gnullvm-0.52.6
  (crate-source "windows_i686_gnullvm" "0.52.6"
                "0rpdx1537mw6slcpqa0rm3qixmsb79nbhqy5fsm3q2q9ik9m5vhf"))

(define rust-windows-i686-msvc-0.48.5
  (crate-source "windows_i686_msvc" "0.48.5"
                "01m4rik437dl9rdf0ndnm2syh10hizvq0dajdkv2fjqcywrw4mcg"))

(define rust-windows-i686-msvc-0.52.6
  (crate-source "windows_i686_msvc" "0.52.6"
                "0rkcqmp4zzmfvrrrx01260q3xkpzi6fzi2x2pgdcdry50ny4h294"))

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

(define rust-windows-sys-0.48.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.48.0"
                "1aan23v5gs7gya1lc46hqn9mdh8yph3fhxmhxlw36pn6pqc28zb7"))

(define rust-windows-sys-0.52.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.52.0"
                "0gd3v4ji88490zgb6b5mq5zgbvwv7zx1ibn8v3x83rwcdbryaar8"))

(define rust-windows-sys-0.59.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.59.0"
                "0fw5672ziw8b3zpmnbp9pdv1famk74f1l9fcbc3zsrzdg56vqf0y"))

(define rust-windows-sys-0.61.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.61.2"
                "1z7k3y9b6b5h52kid57lvmvm05362zv1v8w0gc7xyv5xphlp44xf"))

(define rust-windows-targets-0.48.5
  (crate-source "windows-targets" "0.48.5"
                "034ljxqshifs1lan89xwpcy1hp0lhdh4b5n0d2z4fwjx2piacbws"))

(define rust-windows-targets-0.52.6
  (crate-source "windows-targets" "0.52.6"
                "0wwrx625nwlfp7k93r2rra568gad1mwd888h1jwnl0vfg5r4ywlv"))

(define rust-windows-threading-0.1.0
  (crate-source "windows-threading" "0.1.0"
                "19jpn37zpjj2q7pn07dpq0ay300w65qx7wdp13wbp8qf5snn6r5n"))

(define rust-windows-threading-0.2.1
  (crate-source "windows-threading" "0.2.1"
                "0dsvsy33vxs0153z4n39sqkzx382cjjkrd46rb3z3zfak5dvsj9r"))

(define rust-windows-version-0.1.7
  (crate-source "windows-version" "0.1.7"
                "0c9nnqpcq770977k77mw1p66gpw45khwhqkjdcrd1f89l4fhl1p4"))

(define rust-windows-x86-64-gnu-0.48.5
  (crate-source "windows_x86_64_gnu" "0.48.5"
                "13kiqqcvz2vnyxzydjh73hwgigsdr2z1xpzx313kxll34nyhmm2k"))

(define rust-windows-x86-64-gnu-0.52.6
  (crate-source "windows_x86_64_gnu" "0.52.6"
                "0y0sifqcb56a56mvn7xjgs8g43p33mfqkd8wj1yhrgxzma05qyhl"))

(define rust-windows-x86-64-gnullvm-0.48.5
  (crate-source "windows_x86_64_gnullvm" "0.48.5"
                "1k24810wfbgz8k48c2yknqjmiigmql6kk3knmddkv8k8g1v54yqb"))

(define rust-windows-x86-64-gnullvm-0.52.6
  (crate-source "windows_x86_64_gnullvm" "0.52.6"
                "03gda7zjx1qh8k9nnlgb7m3w3s1xkysg55hkd1wjch8pqhyv5m94"))

(define rust-windows-x86-64-msvc-0.48.5
  (crate-source "windows_x86_64_msvc" "0.48.5"
                "0f4mdp895kkjh9zv8dxvn4pc10xr7839lf5pa9l0193i2pkgr57d"))

(define rust-windows-x86-64-msvc-0.52.6
  (crate-source "windows_x86_64_msvc" "0.52.6"
                "1v7rb5cibyzx8vak29pdrk8nx9hycsjs4w0jgms08qk49jl6v7sq"))

(define rust-winit-0.30.13
  (crate-source "winit" "0.30.13"
                "13cpylyvdl066fivncw96pn29y15rhzlqba73sym10wziajmyxd6"))

(define rust-winnow-0.7.15
  (crate-source "winnow" "0.7.15"
                "0i9rkl2rqpbnnxlgs20gmkj3nd0b2k8q55mjmpc2ybb84xwxjyfz"))

(define rust-winnow-1.0.0
  (crate-source "winnow" "1.0.0"
                "1n67gx8mg2b6r2z54zwbrb6qsfbdsar1lvafsfaajr3jcvj8h3m9"))

(define rust-winnow-1.0.1
  (crate-source "winnow" "1.0.1"
                "1dbji1bwviy08pl74f2qw2m4w9hc4p3vyl3lfj05jdydy59w1nh9"))

(define rust-wit-bindgen-0.46.0
  (crate-source "wit-bindgen" "0.46.0"
                "0ngysw50gp2wrrfxbwgp6dhw1g6sckknsn3wm7l00vaf7n48aypi"))

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

(define rust-x11-dl-2.21.0
  (crate-source "x11-dl" "2.21.0"
                "0vsiq62xpcfm0kn9zjw5c9iycvccxl22jya8wnk18lyxzqj5jwrq"))

(define rust-x11rb-0.13.2
  (crate-source "x11rb" "0.13.2"
                "053lvnaw9ycbl791mgwly2hw27q6vqgzrb1y5kz1as52wmdsm4wr"))

(define rust-x11rb-protocol-0.13.2
  (crate-source "x11rb-protocol" "0.13.2"
                "1g81cznbyn522b0fbis0i44wh3adad2vhsz5pzf99waf3sbc4vza"))

(define rust-xcursor-0.3.10
  (crate-source "xcursor" "0.3.10"
                "0awgy98awg4ydcfmynqfcwvl4bnnfcm4i2vvnk2n926a02jy9jdy"))

(define rust-xkbcommon-0.9.0
  (crate-source "xkbcommon" "0.9.0"
                "0bd0qkapxsvblfw42x6ryhi50d63v55g40awf2alx8b0h3s79ad7"))

(define rust-xkbcommon-dl-0.4.2
  (crate-source "xkbcommon-dl" "0.4.2"
                "1iai0r3b5skd9vbr8z5b0qixiz8jblzfm778ddm8ba596a0dwffh"))

(define rust-xkeysym-0.2.1
  (crate-source "xkeysym" "0.2.1"
                "0mksx670cszyd7jln6s7dhkw11hdfv7blwwr3isq98k22ljh1k5r"))

(define rust-xml-rs-0.8.28
  (crate-source "xml-rs" "0.8.28"
                "0grdj7xwbki5zrkalrg8dljyf14y4yj3wrj34sbzqp06i9zk7s1s"))

(define rust-xshell-0.2.7
  (crate-source "xshell" "0.2.7"
                "0g9pd9bfp0f35rzichic55k7p1mn8mqp607y5rimhiq14g390wly"))

(define rust-xshell-macros-0.2.7
  (crate-source "xshell-macros" "0.2.7"
                "0irm50jxdc92r0kd6yvl5p28jsfzha59brxk7z9w3jcf7z6h1b1j"))

(define rust-yansi-1.0.1
  (crate-source "yansi" "1.0.1"
                "0jdh55jyv0dpd38ij4qh60zglbw9aa8wafqai6m0wa7xaxk3mrfg"))

(define rust-yubico-manager-0.9.0
  (crate-source "yubico_manager" "0.9.0"
                "1vlf0vpfma3gfhlpdss9fhhmsispyakkzn9vd2w3cy7j3110jr7z"))

(define rust-zbus-5.13.2
  (crate-source "zbus" "5.13.2"
                "1ldxqkwy577n7w5ss3lshg9adpyji3vvllj61jr3xahagaczzzhv"))

(define rust-zbus-5.14.0
  (crate-source "zbus" "5.14.0"
                "1g305kwnw9f420c6m10i40cjdjm2s31ddpngac5a8hrrpmfzk0na"))

(define rust-zbus-lockstep-0.5.2
  (crate-source "zbus-lockstep" "0.5.2"
                "0qsqsk67c2vpg26rp0x0ya0cv92fs11r92kjg1sln23s442xx639"))

(define rust-zbus-lockstep-macros-0.5.2
  (crate-source "zbus-lockstep-macros" "0.5.2"
                "1853gk2fymvr2yaird9jpvz4mdp6ms8zmy6dr19payrsgwv0bnhh"))

(define rust-zbus-macros-5.13.2
  (crate-source "zbus_macros" "5.13.2"
                "1wa6z2gzpzna0mww9jj9db9cq573g914ix6y2ddyxzp8vf85mg8b"))

(define rust-zbus-macros-5.14.0
  (crate-source "zbus_macros" "5.14.0"
                "08ljsjl1zhpzdf7hx37yaifi14rvysj354bfqjrc9al4drhpjzl9"))

(define rust-zbus-names-4.3.1
  (crate-source "zbus_names" "4.3.1"
                "03y5f8xwzmk4y5wb4g95a1hl48mxlmhcbwqz62mrnqbqbdnszn7z"))

(define rust-zbus-xml-5.1.0
  (crate-source "zbus_xml" "5.1.0"
                "1b0fp1hf3mqwigjgr0xcfy94v0anxxmsz9n3ridnaraj29j006j4"))

(define rust-zerocopy-0.8.47
  (crate-source "zerocopy" "0.8.47"
                "11zdl3708210fsiax93qbvw8kiadg9lnzriw26xg44g35c32mfzg"))

(define rust-zerocopy-0.8.48
  (crate-source "zerocopy" "0.8.48"
                "1sb8plax8jbrsng1jdval7bdhk7hhrx40dz3hwh074k6knzkgm7f"))

(define rust-zerocopy-derive-0.8.47
  (crate-source "zerocopy-derive" "0.8.47"
                "12dbrk2w8mszdq9v01ls930bi446iyk4llggxrx8whalkckcg2qf"))

(define rust-zerocopy-derive-0.8.48
  (crate-source "zerocopy-derive" "0.8.48"
                "1m5s0g92cxggqc74j83k1priz24k3z93sj5gadppd20p9c4cvqvh"))

(define rust-zeroize-1.8.2
  (crate-source "zeroize" "1.8.2"
                "1l48zxgcv34d7kjskr610zqsm6j2b4fcr2vfh9jm9j1jgvk58wdr"))

(define rust-zmij-1.0.21
  (crate-source "zmij" "1.0.21"
                "1amb5i6gz7yjb0dnmz5y669674pqmwbj44p4yfxfv2ncgvk8x15q"))

(define rust-zvariant-5.10.0
  (crate-source "zvariant" "5.10.0"
                "02sls8pi570z1wssl150413x0mcwqhi9ywlliqsbwfwh46djj22p"))

(define rust-zvariant-5.9.2
  (crate-source "zvariant" "5.9.2"
                "1i1jn8lvsj79lnfyw21lrsimg2jj0gfj6w6wglrm2y8cyks4xdk8"))

(define rust-zvariant-derive-5.10.0
  (crate-source "zvariant_derive" "5.10.0"
                "0b3mh0kzf6sz7vd5j9gimq86awjcigddh26cz5b6di79xc9b0nav"))

(define rust-zvariant-derive-5.9.2
  (crate-source "zvariant_derive" "5.9.2"
                "0p21bv2kzphhcc71597ya3b0m8hr6wyw2adrqqnbbbxpbsbmska8"))

(define rust-zvariant-utils-3.3.0
  (crate-source "zvariant_utils" "3.3.0"
                "1sf5i71in36gc08jhak83pprnkam8gk936cqlq9hzx7q9sk26p7p"))

(define rust-byteorder-1.5.0
  (crate-source "byteorder" "1.5.0"
                "0jzncxyf404mwqdbspihyzpkndfgda450l0893pz5xj685cg5l0z"))

(define rust-cc-1.2.39
  (crate-source "cc" "1.2.39"
                "0py3546wz3k5qi6pbfz80jvg0g3qgzr21c7a1p5wjvscjm4l6dg1"))

(define rust-embedded-io-0.6.1
  (crate-source "embedded-io" "0.6.1"
                "0v901xykajh3zffn6x4cnn4fhgfw3c8qpjwbsk6gai3gaccg3l7d"))

(define rust-find-msvc-tools-0.1.2
  (crate-source "find-msvc-tools" "0.1.2"
                "0nbrhvk4m04hviiwbqp2jwcv9j2k70x0q2kcvfk51iygvaqp7v8w"))

(define rust-goblin-0.10.1
  (crate-source "goblin" "0.10.1"
                "15mamcvgm1m6b870h0s3f8548348cwhx5hzg9zczzmrvsvghma6n"))

(define rust-hash32-0.3.1
  (crate-source "hash32" "0.3.1"
                "01h68z8qi5gl9lnr17nz10lay8wjiidyjdyd60kqx8ibj090pmj7"))

(define rust-heapless-0.9.1
  (crate-source "heapless" "0.9.1"
                "19ddqwmnhi08ia8wnkbqaim4glyg8sl32xfbpn7nhr4f6ddcvvdi"))

(define rust-linux-raw-sys-0.11.0
  (crate-source "linux-raw-sys" "0.11.0"
                "0fghx0nn8nvbz5yzgizfcwd6ap2pislp68j8c1bwyr6sacxkq7fz"))

(define rust-log-0.4.28
  (crate-source "log" "0.4.28"
                "0cklpzrpxafbaq1nyxarhnmcw9z3xcjrad3ch55mmr58xw2ha21l"))

(define rust-plain-0.2.3
  (crate-source "plain" "0.2.3"
                "19n1xbxb4wa7w891268bzf6cbwq4qvdb86bik1z129qb0xnnnndl"))

(define rust-scroll-0.13.0
  (crate-source "scroll" "0.13.0"
                "1pbs3vxhrxcvj9hbjw4hiijbqlz0lkfxc9351mv34hcb4ka7q9f1"))

(define rust-shlex-1.3.0
  (crate-source "shlex" "1.3.0"
                "0r1y6bv26c1scpxvhg2cabimrmwgbp4p3wy6syj9n0c4s3q2znhg"))

(define rust-stable-deref-trait-1.2.0
  (crate-source "stable_deref_trait" "1.2.0"
                "1lxjr8q2n534b2lhkxd6l6wcddzjvnksi58zv11f9y0jjmr15wd8"))


(define rust-abi-stable-0.11.3
  (crate-source "abi_stable" "0.11.3"
                "0if428pq8ly97zi6q1842nak977rwxnj17650i8gwpxh7qnm3mk9"))

(define rust-abi-stable-derive-0.11.3
  (crate-source "abi_stable_derive" "0.11.3"
                "16780mmr2hwx8ajcq59nhvq3krv5i8r7mg41x08fx907nil885yp"))

(define rust-abi-stable-shared-0.11.0
  (crate-source "abi_stable_shared" "0.11.0"
                "0qrbmlypvxx3zij1c6w6yykpp5pjcfx9qr2d9lzyc8y1i1vdzddj"))

(define rust-alloca-0.4.0
  (crate-source "alloca" "0.4.0"
                "1x6p4387rz6j7h342kp3b7bgvqzyl9mibf959pkfk9xflrgd19z5"))

(define rust-anes-0.1.6
  (crate-source "anes" "0.1.6"
                "16bj1ww1xkwzbckk32j2pnbn5vk6wgsl3q4p3j9551xbcarwnijb"))

(define rust-anymap3-1.1.0
  (crate-source "anymap3" "1.1.0"
                "1ya900mqwway69i1m32zc9sr0hgj3pb0ykdyrj4maryjv33gnpgv"))

(define rust-arc-swap-1.9.1
  (crate-source "arc-swap" "1.9.1"
                "01xjlahcya8igdalxmda375lnlhjqwjz0cdqhy0bc1jkyzb1yfka"))

(define rust-arrayvec-0.5.2
  (crate-source "arrayvec" "0.5.2"
                "12q6hn01x5435bprwlb7w9m7817dyfq55yrl4psygr78bp32zdi3"))

(define rust-arrayvec-0.7.7
  (crate-source "arrayvec" "0.7.7"
                "1zjxk501fc4lnkzkdicqsk7y3l3agw89ziqjzcjca6ry9n484a7h"))

(define rust-as-derive-utils-0.11.0
  (crate-source "as_derive_utils" "0.11.0"
                "1i2kwzxdhydicj9bqscz5w73nmx612yi3ha137qlr900b5j9cg7z"))

(define rust-async-ffi-0.5.0
  (crate-source "async-ffi" "0.5.0"
                "0l0s134bsiwwr5f7ifh0ygvh219zjmy7dbsidramlzpgzv023ppl"))

(define rust-autocfg-1.5.1
  (crate-source "autocfg" "1.5.1"
                "0lqasy5i30flcgih1b50kvsk6z32g09r1q4ql7q81pj6228jy0zj"))

(define rust-bigdecimal-0.4.10
  (crate-source "bigdecimal" "0.4.10"
                "159nc0bs6bbzxrpfxbnn83ccyzq8bc2ia40zd22ssfjvavqnfs2d"))

(define rust-bincode-1.3.3
  (crate-source "bincode" "1.3.3"
                "1bfw3mnwzx5g1465kiqllp5n4r10qrqy88kdlp3jfwnq2ya5xx5i"))

(define rust-bitflags-2.13.0
  (crate-source "bitflags" "2.13.0"
                "1y239gpvl061rfvav7jds8mjs42kmwi39is7yx5d1qw3hvp8nf5l"))

(define rust-bitmaps-2.1.0
  (crate-source "bitmaps" "2.1.0"
                "18k4mcwxl96yvii5kcljkpb8pg5j4jj1zbsdn26nsx4r83846403"))

(define rust-bitmaps-3.2.1
  (crate-source "bitmaps" "3.2.1"
                "1mivd3wyyham6c8y21nq3ka29am6v8hqn7lzmwf91aks2fq89l51"))

(define rust-bstr-1.12.1
  (crate-source "bstr" "1.12.1"
                "1arc1v7h5l86vd6z76z3xykjzldqd5icldn7j9d3p7z6x0d4w133"))

(define rust-bumpalo-3.20.3
  (crate-source "bumpalo" "3.20.3"
                "0jc6va3nwcqikm7chnpdv1s87my3gs2j7g1sc7g3k91brg3arxbj"))

(define rust-bytes-1.12.0
  (crate-source "bytes" "1.12.0"
                "14xmxm8imyvw675bsgyadmzm9k63js1sdqh7099p0hlj2p9zbqwa"))

(define rust-cassowary-0.3.0
  (crate-source "cassowary" "0.3.0"
                "0lvanj0gsk6pc1chqrh4k5k0vi1rfbgzmsk46dwy3nmrqyw711nz"))

(define rust-cast-0.3.0
  (crate-source "cast" "0.3.0"
                "1dbyngbyz2qkk0jn2sxil8vrz3rnpcj142y184p9l4nbl9radcip"))

(define rust-castaway-0.2.4
  (crate-source "castaway" "0.2.4"
                "0nn5his5f8q20nkyg1nwb40xc19a08yaj4y76a8q2y3mdsmm3ify"))

(define rust-cc-1.2.65
  (crate-source "cc" "1.2.65"
                "15iv1nizwngnq9if3id4cjjs4pl0rnjkd6xm82vcq5vwpv4ywa72"))

(define rust-chardetng-1.0.0
  (crate-source "chardetng" "1.0.0"
                "0lwbp36klw475vw6c3jqy98frgs1kb2crkm5sgjlw1mm8i599phk"))

(define rust-chrono-0.4.45
  (crate-source "chrono" "0.4.45"
                "09rkcgk6is2sdhqs9142zv8xqnj8ryx8m9hknllqwyv9wxi9x9qs"))

(define rust-ciborium-0.2.2
  (crate-source "ciborium" "0.2.2"
                "03hgfw4674im1pdqblcp77m7rc8x2v828si5570ga5q9dzyrzrj2"))

(define rust-ciborium-io-0.2.2
  (crate-source "ciborium-io" "0.2.2"
                "0my7s5g24hvp1rs1zd1cxapz94inrvqpdf1rslrvxj8618gfmbq5"))

(define rust-ciborium-ll-0.2.2
  (crate-source "ciborium-ll" "0.2.2"
                "1n8g4j5rwkfs3rzfi6g1p7ngmz6m5yxsksryzf5k72ll7mjknrjp"))

(define rust-clipboard-win-5.4.1
  (crate-source "clipboard-win" "5.4.1"
                "1m44gqy11rq1ww7jls86ppif98v6kv2wkwk8p17is86zsdq3gq5x"))

(define rust-clru-0.6.3
  (crate-source "clru" "0.6.3"
                "1mb7vx7s8b3xzx7p2frly9w10b7k2yl3lvrpnvcxba0kn6fdjzqr"))

(define rust-codegen-0.2.0
  (crate-source "codegen" "0.2.0"
                "07f45z842ippz5kblcb4p7iv27kgqr8f1jfwwxq3073pxl52hqgz"))

(define rust-codespan-reporting-0.11.1
  (crate-source "codespan-reporting" "0.11.1"
                "0vkfay0aqk73d33kh79k1kqxx06ka22894xhqi89crnc6c6jff1m"))

(define rust-compact-str-0.8.2
  (crate-source "compact_str" "0.8.2"
                "0ki4hsi2cspj7d3v4xhpn6sakcny3j8jpcsinv6b59anpgmj5mkz"))

(define rust-const-panic-0.2.15
  (crate-source "const_panic" "0.2.15"
                "0lp6i96dnbpal6k6zdmlpmwa2zgbrpwnjff46jpf7514qjmcsqp2"))

(define rust-convert-case-0.10.0
  (crate-source "convert_case" "0.10.0"
                "1fff1x78mp2c233g68my0ag0zrmjdbym8bfyahjbfy4cxza5hd33"))

(define rust-coolor-1.1.0
  (crate-source "coolor" "1.1.0"
                "1wr7q2c8l1cmigw3h7yfdpwcz5g5xbwkirsvbjhdchxgwkyjl34q"))

(define rust-core-extensions-1.5.4
  (crate-source "core_extensions" "1.5.4"
                "00vhspf51swhiq084xfflwkirn0nkkrdmkm6krrlzzb909fmxfs2"))

(define rust-core-extensions-proc-macros-1.5.4
  (crate-source "core_extensions_proc_macros" "1.5.4"
                "1sjr8bfdhxis6xkamrkr52kyk6gb9m8f864fzc47d6vhsbn3hgak"))

(define rust-criterion-0.8.2
  (crate-source "criterion" "0.8.2"
                "1wwq9pfildrkqgb5pq3mwmv297kvvsizkx7m6sjzk4i4mar4c04m"))

(define rust-criterion-plot-0.8.2
  (crate-source "criterion-plot" "0.8.2"
                "1si9mrnzgs0123mr6d5pmhxq29rxph2q6pbvwjal6mav9wphmn6q"))

(define rust-crokey-1.4.0
  (crate-source "crokey" "1.4.0"
                "0z2bhmk3vf6fvhvy8dnb697mvynl7sxcv5xbfif56s510spkv9h4"))

(define rust-crokey-proc-macros-1.4.0
  (crate-source "crokey-proc_macros" "1.4.0"
                "0cdjjdyffz7dvpikxdy2ngp7fgn5jlc84nfhsl5lkz2m92hi2zw4"))

(define rust-crossbeam-0.8.4
  (crate-source "crossbeam" "0.8.4"
                "1a5c7yacnk723x0hfycdbl91ks2nxhwbwy46b8y5vyy0gxzcsdqi"))

(define rust-crossbeam-channel-0.5.15
  (crate-source "crossbeam-channel" "0.5.15"
                "1cicd9ins0fkpfgvz9vhz3m9rpkh6n8d3437c3wnfsdkd3wgif42"))

(define rust-crossbeam-queue-0.3.12
  (crate-source "crossbeam-queue" "0.3.12"
                "059igaxckccj6ndmg45d5yf7cm4ps46c18m21afq3pwiiz1bnn0g"))

(define rust-crossterm-0.28.1
  (crate-source "crossterm" "0.28.1"
                "1im9vs6fvkql0sr378dfr4wdm1rrkrvr22v4i8byz05k1dd9b7c2"))

(define rust-crossterm-0.29.0
  (crate-source "crossterm" "0.29.0"
                "0yzqxxd90k7d2ac26xq1awsznsaq0qika2nv1ik3p0vzqvjg5ffq"))

(define rust-crossterm-winapi-0.9.1
  (crate-source "crossterm_winapi" "0.9.1"
                "0axbfb2ykbwbpf1hmxwpawwfs8wvmkcka5m561l7yp36ldi7rpdc"))

(define rust-crunchy-0.2.4
  (crate-source "crunchy" "0.2.4"
                "1mbp5navim2qr3x48lyvadqblcxc1dm0lqr0swrkkwy2qblvw3s6"))

(define rust-dashmap-6.2.1
  (crate-source "dashmap" "6.2.1"
                "1705w9fx4g30287dx2b0xlmy86l29hnvipba2y5cfq920rf1sdp6"))

(define rust-defmt-1.1.0
  (crate-source "defmt" "1.1.0"
                "0zvzzimxq1zmw3gj42pi326ghihyzhf7pf3w4cyrb8chci829rd6"))

(define rust-defmt-macros-1.1.0
  (crate-source "defmt-macros" "1.1.0"
                "02vaaxgbifai8kchn7nnixyzfa6qyj0q4qwbknkikxy8x5q7g8ph"))

(define rust-defmt-parser-1.0.0
  (crate-source "defmt-parser" "1.0.0"
                "0gpfky9sssil5qfaix5wxcwiqk7snszhl5gq3vcwkrxjncs07mhh"))

(define rust-derive-more-2.1.1
  (crate-source "derive_more" "2.1.1"
                "0d5i10l4aff744jw7v4n8g6cv15rjk5mp0f1z522pc2nj7jfjlfp"))

(define rust-derive-more-impl-2.1.1
  (crate-source "derive_more-impl" "2.1.1"
                "1jwdp836vymp35d7mfvvalplkdgk2683nv3zjlx65n1194k9g6kr"))

(define rust-displaydoc-0.2.6
  (crate-source "displaydoc" "0.2.6"
                "0kyxwfbdmagd8afzb2pzja7wj8dhah7smxdsgw00iq8pa2jhmiqs"))

(define rust-document-features-0.2.12
  (crate-source "document-features" "0.2.12"
                "0qcgpialq3zgvjmsvar9n6v10rfbv6mk6ajl46dd4pj5hn3aif6l"))

(define rust-dunce-1.0.5
  (crate-source "dunce" "1.0.5"
                "04y8wwv3vvcqaqmqzssi6k0ii9gs6fpz96j5w9nky2ccsl23axwj"))

(define rust-either-1.16.0
  (crate-source "either" "1.16.0"
                "17k7jfbdz7k440h6lws9baz8p9zlxgb41sig3w81h80nwzsjyqli"))

(define rust-encoding-rs-0.8.35
  (crate-source "encoding_rs" "0.8.35"
                "1wv64xdrr9v37rqqdjsyb8l8wzlcbab80ryxhrszvnj59wy0y0vm"))

(define rust-encoding-rs-io-0.1.7
  (crate-source "encoding_rs_io" "0.1.7"
                "10ra4l688cdadd8h1lsbahld1zbywnnqv68366mbhamn3xjwbhqw"))

(define rust-env-home-0.1.0
  (crate-source "env_home" "0.1.0"
                "1zn08mk95rjh97831rky1n944k024qrwjhbcgb0xv9zhrh94xy67"))

(define rust-error-code-3.3.2
  (crate-source "error-code" "3.3.2"
                "0nacxm9xr3s1rwd6fabk3qm89fyglahmbi4m512y0hr8ym6dz8ny"))

(define rust-etcetera-0.11.0
  (crate-source "etcetera" "0.11.0"
                "15myc4rl62iah8acdl1sxmrdxb8ci55zbphrv07s55qx3i6wqj6y"))

(define rust-faster-hex-0.10.0
  (crate-source "faster-hex" "0.10.0"
                "0wzvv4a1czxfxmh99cza2y0jps97hm3k1j6r6cs816qp5wnsw8vj"))

(define rust-faststr-0.2.34
  (crate-source "faststr" "0.2.34"
                "04r1031xq0gf97i9zr6amdsbpxy8d4rznfir3jk0ji00496x99qw"))

(define rust-filetime-0.2.29
  (crate-source "filetime" "0.2.29"
                "0napyyfccb26r7fyh9hg7ixrh4vph9h7y7k4iv1j19phqwrpla2w"))

(define rust-foldhash-0.2.0
  (crate-source "foldhash" "0.2.0"
                "1nvgylb099s11xpfm1kn2wcsql080nqmnhj1l25bp3r2b35j9kkp"))

(define rust-generational-arena-0.2.9
  (crate-source "generational-arena" "0.2.9"
                "1rwnfyprjwqafkwdz2irkds5a41jcjb3bsma3djknx4fy2pr8zl7"))

(define rust-generic-singleton-0.5.3
  (crate-source "generic_singleton" "0.5.3"
                "05mblr5c84afdn7v4qi6xbq207bxjv501qp2cg7mg3lpiqy94vmb"))

(define rust-getrandom-0.4.3
  (crate-source "getrandom" "0.4.3"
                "16b0202fkdwz3p2cyll82dv24ljbn0wiyy829v4lwbkbflyqh3ih"))

(define rust-gix-0.84.0
  (crate-source "gix" "0.84.0"
                "1kprx2yxg5qsh09mwn7xkgnlygz6lrf3ppcmilzkqnhspl7awm5f"))

(define rust-gix-actor-0.41.1
  (crate-source "gix-actor" "0.41.1"
                "03w2lz39wy827zns29wcblbdkkljnxiqml2haibaipa6yyw9ijcb"))

(define rust-gix-attributes-0.33.1
  (crate-source "gix-attributes" "0.33.1"
                "00lx9kw0pjg65fw6qn3g9iy2pdm4qidc33sccbngffvd4hpg2hwd"))

(define rust-gix-bitmap-0.3.2
  (crate-source "gix-bitmap" "0.3.2"
                "10qjqn9nzzvdiylcxdsffl87jyvasny7nwlyci3mfc5d4q6fzssj"))

(define rust-gix-chunk-0.7.2
  (crate-source "gix-chunk" "0.7.2"
                "1yraqlp07fcas4dx9wc4hmn4ngmd0r4ml9syvn6yaf5n8dwy9blz"))

(define rust-gix-command-0.9.1
  (crate-source "gix-command" "0.9.1"
                "1xhqj78qgj6bjr18cyv9my5xl374ds623mc02sqg8phkxx7nsw00"))

(define rust-gix-commitgraph-0.37.1
  (crate-source "gix-commitgraph" "0.37.1"
                "1frafvbz653dydj0afrjq13xk2gl38qnzgb4gsjgd9w4yh6msrvz"))

(define rust-gix-config-0.57.0
  (crate-source "gix-config" "0.57.0"
                "1pk3krwwf5z9n1zdajqqy281ip2ysawwll6iwwqq98lwnka748sg"))

(define rust-gix-config-value-0.18.1
  (crate-source "gix-config-value" "0.18.1"
                "1axsw5zvajcaff1kddgd9gc4b78r0k0nb5phblp6qbsm561ichpd"))

(define rust-gix-date-0.15.4
  (crate-source "gix-date" "0.15.4"
                "135llqpx4jnr1bbjnpxr95ylm5rwbvmak419w3wckflbm5japv53"))

(define rust-gix-diff-0.64.0
  (crate-source "gix-diff" "0.64.0"
                "0arhqd3n14wr83jdj65vvm2gr8753z01m6pkxprcx51dycl9av9v"))

(define rust-gix-dir-0.26.0
  (crate-source "gix-dir" "0.26.0"
                "1wd9963r71y9lz77s6brplapmpl7d1dzn2zdk727x4gxlr9jmfr1"))

(define rust-gix-discover-0.52.0
  (crate-source "gix-discover" "0.52.0"
                "1xr4p098lp0y33ij6yhs9rjy95cr64pqric0i8bx4ybq5g8wvfkp"))

(define rust-gix-error-0.2.4
  (crate-source "gix-error" "0.2.4"
                "0sxhk12wb9kwiz6f59n9kv0798fqpsd4aznd1pwhlj5yk7hk2y75"))

(define rust-gix-features-0.48.1
  (crate-source "gix-features" "0.48.1"
                "1g1dlpxvkz87waa5v1q6wqzckqrq3s3zl55yhlql1g1q9laswj8q"))

(define rust-gix-filter-0.31.0
  (crate-source "gix-filter" "0.31.0"
                "1yh9rrnvs1qqczqp8dkl0mqriiz03g279404lgj4qsgn2rylpxzc"))

(define rust-gix-fs-0.21.2
  (crate-source "gix-fs" "0.21.2"
                "1zki0xj5szadpc3hp79xvp9svidag69lpn17yzi4g3krp1nz9pvc"))

(define rust-gix-glob-0.26.1
  (crate-source "gix-glob" "0.26.1"
                "0mip7w7hmwsi861anrykfv49611wpf58vdp9mdsgig0nbgpviz6i"))

(define rust-gix-hash-0.25.1
  (crate-source "gix-hash" "0.25.1"
                "1kpd9vninaiplr9hfscvij5zcwqyj1a7fg70ni87g0wwh79jc2fb"))

(define rust-gix-hashtable-0.15.1
  (crate-source "gix-hashtable" "0.15.1"
                "0qq5pvqbc08wkz09g07ipdsn34p272wzqlw1gnpqnwd8xs9hpqxh"))

(define rust-gix-ignore-0.21.1
  (crate-source "gix-ignore" "0.21.1"
                "13bxm6nfw79fp1kj2c8mlsn66gsx3p1jbx2lqwfk97rcpywvm4fl"))

(define rust-gix-imara-diff-0.2.2
  (crate-source "gix-imara-diff" "0.2.2"
                "069c9v042ich1mrr4ybz5pxr0yh9d6wywl27c10yrl2kv903sx8r"))

(define rust-gix-index-0.52.0
  (crate-source "gix-index" "0.52.0"
                "03d89zvvz1yzlixcggm3j7jjwhaflqabn0l3nnnm7irdb762hssf"))

(define rust-gix-lock-23.0.1
  (crate-source "gix-lock" "23.0.1"
                "0b1wbxszxwg5nywqfkin310jj2af74fj9vfj4ivd9c4hkvfxxjb5"))

(define rust-gix-object-0.61.0
  (crate-source "gix-object" "0.61.0"
                "09fmsqcd41qngg9f12pyfi3i5k7qhgpmlgzgpl9p572255z8bkfm"))

(define rust-gix-odb-0.81.0
  (crate-source "gix-odb" "0.81.0"
                "0zcahpi7w1xvaxysislvq27wfzf9ngnhai47szr5c5cbhlr4q03x"))

(define rust-gix-pack-0.71.0
  (crate-source "gix-pack" "0.71.0"
                "0x5iavzlac0k3kidajfrpgk32hk18nw9d8f19rkk643xlbr2cdp4"))

(define rust-gix-packetline-0.21.5
  (crate-source "gix-packetline" "0.21.5"
                "1mwir05dq8v28vfg6r9p7xgd302g3fdm2jls2v7iw0n4w07ds5xj"))

(define rust-gix-path-0.12.1
  (crate-source "gix-path" "0.12.1"
                "19lk1y6rqvzwkiz7b12vkz012rda1m3ffv299alrx4qlrlaar9mg"))

(define rust-gix-pathspec-0.18.1
  (crate-source "gix-pathspec" "0.18.1"
                "17wcg713gsj89zqra0q3yja63041vwimdcwg3qg524gf84xphl1h"))

(define rust-gix-protocol-0.62.0
  (crate-source "gix-protocol" "0.62.0"
                "1vlm6lq7vr38czlzmvwxhrfvk7j4317miygid2w7lw4hnfna7pji"))

(define rust-gix-quote-0.7.2
  (crate-source "gix-quote" "0.7.2"
                "1vz6db830hm89kmgmj27lzna51hcb920s13rg4xphayc6gy43rd6"))

(define rust-gix-ref-0.64.0
  (crate-source "gix-ref" "0.64.0"
                "12rfdfl4ig2hsjzljcnmwmfwr0gkqs6hy1n7fgmnyzpb6x6gc12c"))

(define rust-gix-refspec-0.42.0
  (crate-source "gix-refspec" "0.42.0"
                "1lx6qpkg1hvgc70zkshhfidr62pvjyljc80ls15g5dblxh3aw5mj"))

(define rust-gix-revision-0.46.0
  (crate-source "gix-revision" "0.46.0"
                "03rlfhblm0kfkf38dp5a14lfmk8z4489v8cxlccilg6xhj4chiqb"))

(define rust-gix-revwalk-0.32.0
  (crate-source "gix-revwalk" "0.32.0"
                "1rpr3rlb0yglp3ws33rrpisrinafd09kns5cga11f2gypxm7bxc5"))

(define rust-gix-sec-0.14.1
  (crate-source "gix-sec" "0.14.1"
                "1cq1bl9a3kwlglvx22xqg43r8dwz6q0582klf1i4hzjcdsbik1db"))

(define rust-gix-shallow-0.12.1
  (crate-source "gix-shallow" "0.12.1"
                "15ydacjzi1nkmv3gxwan5zfz3pdh8ns1d7a7fnjxzia8wlpzr4m2"))

(define rust-gix-status-0.31.0
  (crate-source "gix-status" "0.31.0"
                "0047xpr26yc9r9c3c1xr2jz4al18f14qzn99w1sl58r8blw2w112"))

(define rust-gix-submodule-0.31.0
  (crate-source "gix-submodule" "0.31.0"
                "10a7i24gv0spksya0c6nvjp0dn50mcz6mz2bm4i6q1jly078jn9h"))

(define rust-gix-tempfile-23.0.1
  (crate-source "gix-tempfile" "23.0.1"
                "08nv9866jl4lmfmjsxr74ybhw0lxkighzb8ddbs1b5gzw6bh1197"))

(define rust-gix-trace-0.1.20
  (crate-source "gix-trace" "0.1.20"
                "0y6n39aay8pd7ad9k9mn8m6wyk92dqp1a3ry2wafph45wzm4bp24"))

(define rust-gix-transport-0.57.1
  (crate-source "gix-transport" "0.57.1"
                "1zz78r02cqs4c0197j0rw79zl2vafbdzhapzipxb1amijm4y7l3w"))

(define rust-gix-traverse-0.58.0
  (crate-source "gix-traverse" "0.58.0"
                "1vbs3z6q3p8g0972vz67fa37z7zs4j1jiwk50s3v58w6rh75kpp8"))

(define rust-gix-url-0.36.1
  (crate-source "gix-url" "0.36.1"
                "1cksnqmy50fxpz7ahqw4qfmfdm7a052jd7m1nz684pnmd7n03fv5"))

(define rust-gix-utils-0.3.3
  (crate-source "gix-utils" "0.3.3"
                "0wdpn67c6rlmw67ypz67y6bqb1qs0cl4x9pzh3swl8s131k0kib6"))

(define rust-gix-validate-0.11.2
  (crate-source "gix-validate" "0.11.2"
                "1qzs9bzb0x48ggzbfr1vh9m1q9bnc3xr2yzls9yblqs03ivzrikv"))

(define rust-gix-worktree-0.53.0
  (crate-source "gix-worktree" "0.53.0"
                "1ld2aks5hys16hj9v19zvnq015z17gl03lskbp6hg12y4zni9x6f"))

(define rust-gix-worktree-stream-0.33.0
  (crate-source "gix-worktree-stream" "0.33.0"
                "0my5vkvhg73k8ni7kah67sjk3xskbqi1qn5wj1skzih0079rwpnj"))

(define rust-globset-0.4.18
  (crate-source "globset" "0.4.18"
                "1qsp3wg0mgxzmshcgymdlpivqlc1bihm6133pl6dx2x4af8w3psj"))

(define rust-grep-matcher-0.1.8
  (crate-source "grep-matcher" "0.1.8"
                "08w0i8iai5y672fp3fhqnpmlmbk663gxfh0bg0nv4nijjc8bgmrn"))

(define rust-grep-regex-0.1.14
  (crate-source "grep-regex" "0.1.14"
                "1vqjf7dk8lk9jr7i45cf5q99ily1bsj1ab41gg0br0mdqdbc5q0c"))

(define rust-grep-searcher-0.1.16
  (crate-source "grep-searcher" "0.1.16"
                "0d6wfw2vr8n2pwqzar4fi0c670axj13q2d151arfnj6w499jjqxc"))

(define rust-half-2.7.1
  (crate-source "half" "2.7.1"
                "0jyq42xfa6sghc397mx84av7fayd4xfxr4jahsqv90lmjr5xi8kf"))

(define rust-hashbrown-0.17.1
  (crate-source "hashbrown" "0.17.1"
                "0jmqz7i4yl6cm7rbn0i2ffkfrmwi6xkmzkaldr2v8bcsx2v0jngd"))

(define rust-heapless-0.8.0
  (crate-source "heapless" "0.8.0"
                "1b9zpdjv4qkl2511s2c80fz16fx9in4m9qkhbaa8j73032v9xyqb"))

(define rust-home-0.5.12
  (crate-source "home" "0.5.12"
                "13bjyzgx6q9srnfvl43dvmhn93qc8mh5w7cylk2g13sj3i3pyqnc"))

(define rust-httparse-1.10.1
  (crate-source "httparse" "1.10.1"
                "11ycd554bw2dkgw0q61xsa7a4jn1wb1xbfacmf3dbwsikvkkvgvd"))

(define rust-icu-casemap-2.2.0
  (crate-source "icu_casemap" "2.2.0"
                "1gn5bk6r443ix84imxc69k24y1j0kznrdgsl6swzr617p2srh3q7"))

(define rust-icu-casemap-data-2.2.0
  (crate-source "icu_casemap_data" "2.2.0"
                "0jq1k0fng3zy7w6hplnjx1vlg7gqm8ywjjw77jz084h9r9bhhsw4"))

(define rust-icu-collections-2.2.0
  (crate-source "icu_collections" "2.2.0"
                "070r7xd0pynm0hnc1v2jzlbxka6wf50f81wybf9xg0y82v6x3119"))

(define rust-icu-locale-core-2.2.0
  (crate-source "icu_locale_core" "2.2.0"
                "0a9cmin5w1x3bg941dlmgszn33qgq428k7qiqn5did72ndi9n8cj"))

(define rust-icu-properties-2.2.0
  (crate-source "icu_properties" "2.2.0"
                "1pkh3s837808cbwxvfagwc28cvwrz2d9h5rl02jwrhm51ryvdqxy"))

(define rust-icu-properties-data-2.2.0
  (crate-source "icu_properties_data" "2.2.0"
                "052awny0qwkbcbpd5jg2cd7vl5ry26pq4hz1nfsgf10c3qhbnawf"))

(define rust-icu-provider-2.2.0
  (crate-source "icu_provider" "2.2.0"
                "08dl8pxbwr8zsz4c5vphqb7xw0hykkznwi4rw7bk6pwb3krlr70k"))

(define rust-ignore-0.4.26
  (crate-source "ignore" "0.4.26"
                "0zg65dcwq8qnni4jg3iqj8vpnln6pivj8nr6a18g1cqxs0fnc5dr"))

(define rust-im-15.1.0
  (crate-source "im" "15.1.0"
                "1sg0jy9y0l3lqjpjyclj6kspi027mx177dgrmacgjni8y0zx7b6h"))

(define rust-im-lists-0.12.2
  (crate-source "im-lists" "0.12.2"
                "141j9j30wssvy0jnrbhk5ikvvzzbkmhcy6hz3p615wrcv18lda7g"))

(define rust-im-rc-15.1.0
  (crate-source "im-rc" "15.1.0"
                "1zp5vdjj4b4lg8jnrz0wmdln2cdd9gn24a4psdvwd050bykma6dg"))

(define rust-imara-diff-0.2.0
  (crate-source "imara-diff" "0.2.0"
                "0p2wmak4pbqfa93fihply18kq8q0nxg6zl0dhampipv6yxid809g"))

(define rust-imbl-sized-chunks-0.1.3
  (crate-source "imbl-sized-chunks" "0.1.3"
                "0bf2abqdcpzw7ma2hirh6w0nxf8ga41bvzmjay6jz9hqaq042hlg"))

(define rust-indoc-2.0.7
  (crate-source "indoc" "2.0.7"
                "01np60qdq6lvgh8ww2caajn9j4dibx9n58rvzf7cya1jz69mrkvr"))

(define rust-is-docker-0.2.0
  (crate-source "is-docker" "0.2.0"
                "1cyibrv6817cqcpf391m327ss40xlbik8wxcv5h9pj9byhksx2wj"))

(define rust-is-wsl-0.4.0
  (crate-source "is-wsl" "0.4.0"
                "19bs5pq221d4bknnwiqqkqrnsx2in0fsk8fylxm1747iim4hjdhp"))

(define rust-jiff-0.2.29
  (crate-source "jiff" "0.2.29"
                "0ipb184wk3hhs02hyxwcrs2c9rhwlp34rmwq8rkgplknhslpgy1l"))

(define rust-jiff-static-0.2.29
  (crate-source "jiff-static" "0.2.29"
                "0pzjhq4zbahp01z9lprdxs24w06rhc08qnx8q8zj3jnabsmvarh6"))

(define rust-jiff-tzdb-0.1.6
  (crate-source "jiff-tzdb" "0.1.6"
                "0xihzlnnyk0xnrzpq4xcyjdcmy8xc3ychzb9ayjkh4vgha2fy069"))

(define rust-jiff-tzdb-platform-0.1.3
  (crate-source "jiff-tzdb-platform" "0.1.3"
                "1s1ja692wyhbv7f60mc0x90h7kn1pv65xkqi2y4imarbmilmlnl7"))

(define rust-js-sys-0.3.102
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.102"
                "0cgxklnyrfpzvf32cvdl3x5d070kfsv7ykdxfl3yizwdjqq4rl03"))

(define rust-kstring-2.0.2
  (crate-source "kstring" "2.0.2"
                "1lfvqlqkg2x23nglznb7ah6fk3vv3y5i759h5l2151ami98gk2sm"))

(define rust-lasso-0.7.3
  (crate-source "lasso" "0.7.3"
                "1yz92fy2zv6wslfwwf3j7lw1wxja8d91rrcwgfzv751l1ajys53f"))

(define rust-lazy-regex-3.6.0
  (crate-source "lazy-regex" "3.6.0"
                "15hlmhjh7abkvb91ac1gpw58fvfvra8s56ny8xqyrlvnjh0r3bkb"))

(define rust-lazy-regex-proc-macros-3.6.0
  (crate-source "lazy-regex-proc_macros" "3.6.0"
                "0n23v742vgza04y9lgbk84ra6z24ky00klmjc4q7p2wx8ghw3sad"))

(define rust-libc-0.2.186
  (crate-source "libc" "0.2.186"
                "0rnyhzjyqq9x56skkllbjzzzwym3r61lq3l4hqj64v71gw0r3av8"))

(define rust-libloading-0.7.4
  (crate-source "libloading" "0.7.4"
                "17wbccnjvhjd9ibh019xcd8kjvqws8lqgq86lqkpbgig7gyq0wxn"))

(define rust-litemap-0.8.2
  (crate-source "litemap" "0.8.2"
                "1w7628bc7wwcxc4n4s5kw0610xk06710nh2hn5kwwk2wa91z9nlj"))

(define rust-litrs-1.0.0
  (crate-source "litrs" "1.0.0"
                "14p0kzzkavnngvybl88nvfwv031cc2qx4vaxpfwsiifm8grdglqi"))

(define rust-lock-api-0.4.14
  (crate-source "lock_api" "0.4.14"
                "0rg9mhx7vdpajfxvdjmgmlyrn20ligzqvn8ifmaz7dc79gkrjhr2"))

(define rust-log-0.4.33
  (crate-source "log" "0.4.33"
                "1bd9dmk22pxgnf0h0slba6rz99zb0a0b2mdhpk8p92bp26ycbvhc"))

(define rust-maybe-async-0.2.11
  (crate-source "maybe-async" "0.2.11"
                "036anp4dzz7sjgdq3zfwzf52ggblpbx1sivlvg2ssq5dhjip6s3l"))

(define rust-md-5-0.10.6
  (crate-source "md-5" "0.10.6"
                "1kvq5rnpm4fzwmyv5nmnxygdhhb2369888a06gdc9pxyrzh7x7nq"))

(define rust-memchr-2.8.2
  (crate-source "memchr" "2.8.2"
                "1i33wr49pcz2sbd12nds3n9fszay8kq5bk78gwciz462mcs49448"))

(define rust-minimad-0.13.1
  (crate-source "minimad" "0.13.1"
                "1lj5szpri8hjf38qrmg0i7vabp9b1rwakm5nly86a63d484dgid9"))

(define rust-mio-1.2.1
  (crate-source "mio" "1.2.1"
                "1nkggmrlnjs93w8rja4lvjj4aml1xqahgimv1h0p7d373kvhmg82"))

(define rust-munge-0.4.7
  (crate-source "munge" "0.4.7"
                "032sj47l2174dirkjkhi18x92wlgdqdld4b4l5n9bfly4lgl05sy"))

(define rust-munge-macro-0.4.7
  (crate-source "munge_macro" "0.4.7"
                "0cgrm4q8a6qm0802d08pacbv2mpcq4c47hrxc3avannlrdfg4s25"))

(define rust-nonempty-0.12.0
  (crate-source "nonempty" "0.12.0"
                "1dpc3xi8bd8dynkh42b0ysv8w4b5hvidmvcqdxrx0p1y6lkf0dwp"))

(define rust-nucleo-0.5.0
  (crate-source "nucleo" "0.5.0"
                "1m1rq0cp02hk31z7jsn2inqcpy9a1j8gfvxcqm32c74jji6ayqjj"))

(define rust-nucleo-matcher-0.3.1
  (crate-source "nucleo-matcher" "0.3.1"
                "11dc5kfin1n561qdcg0x9aflvw876a8vldmqjhs5l6ixfcwgacxz"))

(define rust-num-bigint-0.4.6
  (crate-source "num-bigint" "0.4.6"
                "1f903zd33i6hkjpsgwhqwi2wffnvkxbn6rv4mkgcjcqi7xr4zr55"))

(define rust-num-integer-0.1.46
  (crate-source "num-integer" "0.1.46"
                "13w5g54a9184cqlbsq80rnxw4jj4s0d8wv75jsq5r2lms8gncsbr"))

(define rust-num-rational-0.4.2
  (crate-source "num-rational" "0.4.2"
                "093qndy02817vpgcqjnj139im3jl7vkq4h68kykdqqh577d18ggq"))

(define rust-num-cpus-1.17.0
  (crate-source "num_cpus" "1.17.0"
                "0fxjazlng4z8cgbmsvbzv411wrg7x3hyxdq8nxixgzjswyylppwi"))

(define rust-oorandom-11.1.5
  (crate-source "oorandom" "11.1.5"
                "07mlf13z453fq01qff38big1lh83j8l6aaglf63ksqzzqxc0yyfn"))

(define rust-open-5.3.5
  (crate-source "open" "5.3.5"
                "0b691z6jf5gk3sbjmq5qhg22iyngm3p6kprsib3p716w5nfsifig"))

(define rust-page-size-0.6.0
  (crate-source "page_size" "0.6.0"
                "1nj0rrwpvagagssljbm29ww1iyrrg15p1q4sk70r2cfi9qcv5m9h"))

(define rust-parking-lot-0.12.5
  (crate-source "parking_lot" "0.12.5"
                "06jsqh9aqmc94j2rlm8gpccilqm6bskbd67zf6ypfc0f4m9p91ck"))

(define rust-parking-lot-core-0.9.12
  (crate-source "parking_lot_core" "0.9.12"
                "1hb4rggy70fwa1w9nb0svbyflzdc69h047482v2z3sx2hmcnh896"))

(define rust-pathdiff-0.2.3
  (crate-source "pathdiff" "0.2.3"
                "1lrqp4ip05df8dzldq6gb2c1sq2gs54gly8lcnv3rhav1qhwx56z"))

(define rust-portable-atomic-1.13.1
  (crate-source "portable-atomic" "1.13.1"
                "0j8vlar3n5acyigq8q6f4wjx3k3s5yz0rlpqrv76j73gi5qr8fn3"))

(define rust-portable-atomic-util-0.2.7
  (crate-source "portable-atomic-util" "0.2.7"
                "0616j0fhy6y71hyxg3n86f6hng0fmsc269s3wp4gl8ww4p8hd8f2"))

(define rust-potential-utf-0.1.5
  (crate-source "potential_utf" "0.1.5"
                "0r0518fr32xbkgzqap509s3r60cr0iancsg9j1jgf37cyz7b20q1"))

(define rust-pretty-0.12.5
  (crate-source "pretty" "0.12.5"
                "0mj1bwnam0ixd3dkyyly1lagxwww447g7r4h8ls90c8rhwj1a8hd"))

(define rust-proc-macro-error-attr2-2.0.0
  (crate-source "proc-macro-error-attr2" "2.0.0"
                "1ifzi763l7swl258d8ar4wbpxj4c9c2im7zy89avm6xv6vgl5pln"))

(define rust-proc-macro-error2-2.0.1
  (crate-source "proc-macro-error2" "2.0.1"
                "00lq21vgh7mvyx51nwxwf822w2fpww1x0z8z0q47p8705g2hbv0i"))

(define rust-prodash-31.0.0
  (crate-source "prodash" "31.0.0"
                "0k304x706f6ykvm313hrvad02x432f2wxzfrjw94alfmszi008ln"))

(define rust-ptr-meta-0.3.1
  (crate-source "ptr_meta" "0.3.1"
                "0yaa4bvghj0rygqjlcd4lkcid58pcywxmjzisihsz5hibbwhr6hb"))

(define rust-ptr-meta-derive-0.3.1
  (crate-source "ptr_meta_derive" "0.3.1"
                "1qbg3malg24dmiszfddd7n69g3rb7vl7nxj67gchh4ky19yqcivk"))

(define rust-pulldown-cmark-0.13.4
  (crate-source "pulldown-cmark" "0.13.4"
                "0kii5zdm7nvdjh7rjkjpvxd0sx1cyd21p0qijmgiq1z7m3mniw79"))

(define rust-quickcheck-1.1.0
  (crate-source "quickcheck" "1.1.0"
                "02zpl1i6xkfr2kw09j3h2ig0z4n63xxx4z4a2sm6l3yv6prqkicm"))

(define rust-rancor-0.1.1
  (crate-source "rancor" "0.1.1"
                "1vl1y0yhw40j3g6b2h9jgkfjp0pg000cia8xashc49qm71rflqx0"))

(define rust-rand-0.8.6
  (crate-source "rand" "0.8.6"
                "12kd4rljn86m00rcaz4c1rcya4mb4gk5ig6i8xq00a8wjgxfr82w"))

(define rust-rand-0.10.1
  (crate-source "rand" "0.10.1"
                "01r22vdpw6z69jzy6khnyr0ljq9im337h4j0mkyz26lnqyyfis6j"))

(define rust-rand-core-0.10.1
  (crate-source "rand_core" "0.10.1"
                "0s9wiacxrr100icl7i41308gcj85nlcclrc5jx1jd6p10dhigf33"))

(define rust-rand-xoshiro-0.6.0
  (crate-source "rand_xoshiro" "0.6.0"
                "1ajsic84rzwz5qr0mzlay8vi17swqi684bqvwqyiim3flfrcv5vg"))

(define rust-rand-xoshiro-0.7.0
  (crate-source "rand_xoshiro" "0.7.0"
                "0h9dv9mn703zb2z5dys7vc4rzy3az8xg99fc5m8zbnh0axkg80zp"))

(define rust-redox-syscall-0.5.18
  (crate-source "redox_syscall" "0.5.18"
                "0b9n38zsxylql36vybw18if68yc9jczxmbyzdwyhb9sifmag4azd"))

(define rust-regex-1.12.4
  (crate-source "regex" "1.12.4"
                "1fm6si2xpmhwqflabdqsakc0qkq718wx2ljl37nbj75fb5vjnagi"))

(define rust-regex-cursor-0.1.5
  (crate-source "regex-cursor" "0.1.5"
                "07d64dfcg361mn7mxahxajj5hzl7dbp2m4yjhj1ax0prsa0wg5q4"))

(define rust-regex-syntax-0.8.11
  (crate-source "regex-syntax" "0.8.11"
                "1m25h5q2wp976fb9gc3dsc9l99svcvd5cri8lncb51c46ydgzxnn"))

(define rust-rend-0.5.3
  (crate-source "rend" "0.5.3"
                "1rknl9l1s3x67zizrxz1n3k8w5z7z54dqzsdlrahgwn22zrxxnna"))

(define rust-repr-offset-0.2.2
  (crate-source "repr_offset" "0.2.2"
                "1skj3cy77j7vwslnjjzgladq61z6jjvwlw89kp0zz7fjbdsp047v"))

(define rust-rkyv-0.8.16
  (crate-source "rkyv" "0.8.16"
                "1qqn1ylmdbqykgzis7p6indgx48k8yqbbdas4wczjr76k469wf3k"))

(define rust-rkyv-derive-0.8.16
  (crate-source "rkyv_derive" "0.8.16"
                "1ina2cfv6iiz915n6wgq91ji472d64nyh8fhdfrmyc9586sx0bjx"))

(define rust-ropey-1.6.1
  (crate-source "ropey" "1.6.1"
                "1dckf3likfi1my2ilqwhq2ifsm9iq8cayg6ws7fpa6nd1d11whck"))

(define rust-ryu-1.0.23
  (crate-source "ryu" "1.0.23"
                "0zs70sg00l2fb9jwrf6cbkdyscjs53anrvai2hf7npyyfi5blx4p"))

(define rust-safe-arch-0.7.4
  (crate-source "safe_arch" "0.7.4"
                "08sk47n1kcm5w2di6bpgi2hsw8r2caz2230pwqvbdqfv5pl2vc4n"))

(define rust-scopeguard-1.2.0
  (crate-source "scopeguard" "1.2.0"
                "0jcz9sd47zlsgcnm1hdw0664krxwb5gczlif4qngj2aif8vky54l"))

(define rust-serde-json-1.0.150
  (crate-source "serde_json" "1.0.150"
                "1ffgfhy9kndjnrz8lmy95pr758p2zk8dxv6yi99x0vkkni24w0g8"))

(define rust-sha1-0.10.6
  (crate-source "sha1" "0.10.6"
                "1fnnxlfg08xhkmwf2ahv634as30l1i3xhlhkvxflmasi5nd85gz3"))

(define rust-sha1-checked-0.10.0
  (crate-source "sha1-checked" "0.10.0"
                "08s4h1drgwxzfn1mk11rn0r9i0rbjra1m0l2c0fbngij1jn9kxc9"))

(define rust-shared-vector-0.4.5
  (crate-source "shared_vector" "0.4.5"
                "18kjcv1fbm7xf7gd0b89n52gzqm3q86i806pd4g2gkxgm7zaqfk7"))

(define rust-shell-words-1.1.1
  (crate-source "shell-words" "1.1.1"
                "0xzd5p53xl0ndnk63r0by52rhdrh6pd37szfxszkg73zb6ffcvyw"))

(define rust-shlex-2.0.1
  (crate-source "shlex" "2.0.1"
                "1fjsll1cd7d2bcpdij9kd6w62rpbc7qqzvydvs021vsmr1cxvypq"))

(define rust-signal-hook-0.3.18
  (crate-source "signal-hook" "0.3.18"
                "1qnnbq4g2vixfmlv28i1whkr0hikrf1bsc4xjy2aasj2yina30fq"))

(define rust-signal-hook-0.4.4
  (crate-source "signal-hook" "0.4.4"
                "0gdm8kmi1mcd30gkxcwagxiqiasq0fhdlvrfsnybv3chln6c585j"))

(define rust-signal-hook-mio-0.2.5
  (crate-source "signal-hook-mio" "0.2.5"
                "1k20rr76ngvmzr6kskkl7dv8iyb84cbydpjbjk3mpcj0lykijnmp"))

(define rust-signal-hook-tokio-0.4.0
  (crate-source "signal-hook-tokio" "0.4.0"
                "1w4c6wnjvjl3d7j00kawzc49g1xp12kx0a8g4w1012l9m0sy84z5"))

(define rust-sized-chunks-0.6.5
  (crate-source "sized-chunks" "0.6.5"
                "07ix5fsdnpf2xsb0k5rbiwlmsicm2237fcx7blirp9p7pljr5mhn"))

(define rust-slotmap-1.1.1
  (crate-source "slotmap" "1.1.1"
                "0f20xf53zaysx9ydzkwwqm6hsjyb8lj2j6amhg57iln3jcy8rmdx"))

(define rust-smallvec-1.15.2
  (crate-source "smallvec" "1.15.2"
                "143wzbqf6vgapdp2z4qpl0yvlqcn17s8cnk8m28rqly808zsdmlf"))

(define rust-smartstring-1.0.1
  (crate-source "smartstring" "1.0.1"
                "0agf4x0jz79r30aqibyfjm1h9hrjdh0harcqcvb2vapv7rijrdrz"))

(define rust-smawk-0.3.3
  (crate-source "smawk" "0.3.3"
                "006id1vx7vv7vdnmj0ss5dla34ggymlavv9b5wb4vfws947zpqp8"))

(define rust-socket2-0.6.4
  (crate-source "socket2" "0.6.4"
                "0ldyp5rhba15spwxj1n94xh7sjks1398c3vwpwkxkd1087nwzlaj"))

(define rust-sonic-number-0.1.2
  (crate-source "sonic-number" "0.1.2"
                "0cmz3nb747v2rc21dkpks3mzw1w931f8q7mby68q35fz1qww6x9p"))

(define rust-sonic-rs-0.5.8
  (crate-source "sonic-rs" "0.5.8"
                "0krc1xnhbv1ysh86a2b42hcw02gpwz1qf6mxdmsz3k25l9vwqwfr"))

(define rust-sonic-simd-0.1.4
  (crate-source "sonic-simd" "0.1.4"
                "1m0pz10lmmd4mf2fjpc3kvm4gxliwv7s7iz3hy6ad19drm76d7pr"))

(define rust-stable-deref-trait-1.2.1
  (crate-source "stable_deref_trait" "1.2.1"
                "15h5h73ppqyhdhx6ywxfj88azmrpml9gl6zp3pwy2malqa6vxqkc"))

(define rust-steel-core-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-core" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-derive-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-derive" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-doc-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-doc" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-gen-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-gen" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-imbl-7.1.0
  (crate-source "steel-imbl" "7.1.0"
                "07fif1skvjihwfqi4j74bl8bjk3jqr0hfb19pqzgcx4iaswkipzr"))

(define rust-steel-parser-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-parser" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-quickscope-0.3.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-quickscope" "0.3.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-steel-rc-0.8.3.118fb9f
  ;; TODO REVIEW: Define standalone package if this is a workspace.
  (origin
    (method git-fetch)
    (uri (git-reference
          (url "https://github.com/mattwparas/steel.git")
          (commit "118fb9f9257dd518db92c093e230c3392b8fd520")))
    (file-name (git-file-name "rust-steel-rc" "0.8.3.118fb9f"))
    (sha256 (base32 "02l947yrc993092nfa8cxjp31ms7ibh8cira0ylnyn2gp0kbcvga"))))

(define rust-str-indices-0.4.4
  (crate-source "str_indices" "0.4.4"
                "1rj7xrvv5m97qiqwqk1sqxazyggrw7h8kbb6vc438s08akn8k26h"))

(define rust-strict-0.2.0
  (crate-source "strict" "0.2.0"
                "01j0h28xzg07kd1km5m0wz88asp6hwh45n8q8bdkjymqlpz4897l"))

(define rust-syn-2.0.118
  (crate-source "syn" "2.0.118"
                "08hlbc32lqd5d67p26ck7chg0rkclsw9as6f96vfn4s2j1zyb6hv"))

(define rust-synstructure-0.13.2
  (crate-source "synstructure" "0.13.2"
                "1lh9lx3r3jb18f8sbj29am5hm9jymvbwh6jb1izsnnxgvgrp12kj"))

(define rust-termimad-0.31.3
  (crate-source "termimad" "0.31.3"
                "1dnbqanrhahx6vy94h74vvpqy7ri2cy0vdvnagr9g74kqk1dj0bk"))

(define rust-termina-0.3.3
  (crate-source "termina" "0.3.3"
                "0km0c8zdpprqin2i1r9vr9nv362i519pzbz0vv6sad7yxy4shj4h"))

(define rust-termini-1.0.0
  (crate-source "termini" "1.0.0"
                "0n8dvbwkp2k673xqwivb01iqg5ir91zgpwhwngpcb2yrgpc43m1a"))

(define rust-thin-vec-0.2.18
  (crate-source "thin-vec" "0.2.18"
                "10ml7530igcr5xdnl21z6z07zihcnljgm0362k87s2lgnily5xxh"))

(define rust-threadpool-1.8.1
  (crate-source "threadpool" "1.8.1"
                "1amgfyzvynbm8pacniivzq9r0fh3chhs7kijic81j76l6c5ycl6h"))

(define rust-tinystr-0.8.3
  (crate-source "tinystr" "0.8.3"
                "0vfr8x285w6zsqhna0a9jyhylwiafb2kc8pj2qaqaahw48236cn8"))

(define rust-tinytemplate-1.2.1
  (crate-source "tinytemplate" "1.2.1"
                "1g5n77cqkdh9hy75zdb01adxn45mkh9y40wdr7l68xpz35gnnkdy"))

(define rust-tinyvec-1.11.0
  (crate-source "tinyvec" "1.11.0"
                "1wvycrghzmaysnw34kzwnf0mfx6r75045s24r214wnnjadqfcq9y"))

(define rust-tinyvec-macros-0.1.1
  (crate-source "tinyvec_macros" "0.1.1"
                "081gag86208sc3y6sdkshgw3vysm5d34p431dzw0bshz66ncng0z"))

(define rust-tokio-1.52.3
  (crate-source "tokio" "1.52.3"
                "1zpzazypkg61sw91na1m85x5s4rsjym335fwwhwm1hcs70dz1iwg"))

(define rust-tokio-macros-2.7.0
  (crate-source "tokio-macros" "2.7.0"
                "15m4f37mdafs0gg36sh0rskm1i768lb7zmp8bw67kaxr3avnqniq"))

(define rust-tokio-stream-0.1.18
  (crate-source "tokio-stream" "0.1.18"
                "0w3cj33605ab58wqd382gnla5pnd9hnr00xgg333np5bka04knij"))

(define rust-tree-house-0.4.0
  (crate-source "tree-house" "0.4.0"
                "1cfp46r6ysl34hscq9y7jw3kvnskmrix5km896r5l8425127cd1k"))

(define rust-tree-house-bindings-0.3.2
  (crate-source "tree-house-bindings" "0.3.2"
                "03zbbpfkh76p8a12zwg1mlmifz1z85pqz2srirhpi1dr1pnhwpbg"))

(define rust-tstr-0.2.4
  (crate-source "tstr" "0.2.4"
                "19yvgfipfrqjymvfi7cs6ipdc91f1dw2s2nxs1vf9ajby6a053kz"))

(define rust-tstr-proc-macros-0.2.2
  (crate-source "tstr_proc_macros" "0.2.2"
                "0yklq0k0s3c4y0k5f0qm13lw7nvz5z97x3yhmyw1if0cdc3250g7"))

(define rust-typed-arena-2.0.2
  (crate-source "typed-arena" "2.0.2"
                "0shj0jpmglhgw2f1i4b33ycdzwd1z205pbs1rd5wx7ks2qhaxxka"))

(define rust-typenum-1.20.1
  (crate-source "typenum" "1.20.1"
                "086s9ly0906kw5yw41249fba97w5zfxf03pyfwdkffvcprqfixdn"))

(define rust-typewit-1.15.2
  (crate-source "typewit" "1.15.2"
                "1xmmbcykcn6xrsrp8dd3bfdy6j70c4ccmf89cb0cp18p36ra0k11"))

(define rust-uluru-3.1.0
  (crate-source "uluru" "3.1.0"
                "1njp6vvy1mm8idnsp6ljyxx5znfsk3xkmk9cr2am0vkfwmlj92kw"))

(define rust-unicase-2.9.0
  (crate-source "unicase" "2.9.0"
                "0hh1wrfd7807mfph2q67jsxqgw8hm82xg2fb8ln8cvblkwxbri6v"))

(define rust-unicode-bom-2.0.3
  (crate-source "unicode-bom" "2.0.3"
                "05s2sqyjanqrbds3fxam35f92npp5ci2wz9zg7v690r0448mvv3y"))

(define rust-unicode-general-category-1.1.0
  (crate-source "unicode-general-category" "1.1.0"
                "0zv7q4fdnlawjxd75bpxfll33sf3db09xd13sv85pblkq7fkp68b"))

(define rust-unicode-normalization-0.1.25
  (crate-source "unicode-normalization" "0.1.25"
                "1s76dcrxw7vs32yhpi0p074apdc3s7lak7809f3qvclwij3zdm2z"))

(define rust-unicode-segmentation-1.13.3
  (crate-source "unicode-segmentation" "1.13.3"
                "1a47zaq83p386r3baq4m018xd5q4q0grdg56i1x042dzn71x7xf6"))

(define rust-unicode-width-0.1.12
  (crate-source "unicode-width" "0.1.12"
                "1mk6mybsmi5py8hf8zy9vbgs4rw4gkdqdq3gzywd9kwf2prybxb8"))

(define rust-utf8-iter-1.0.4
  (crate-source "utf8_iter" "1.0.4"
                "1gmna9flnj8dbyd8ba17zigrp9c4c3zclngf5lnb5yvz1ri41hdn"))

(define rust-uuid-1.23.3
  (crate-source "uuid" "1.23.3"
                "1drddl03gi12vl1s3l2h371dw39plhn9wappp00v707g7h96nk8l"))

(define rust-wasip2-1.0.4+wasi-0.2.12
  (crate-source "wasip2" "1.0.4+wasi-0.2.12"
                "11wl7lqwq4pbmlmzr6n7bwz0hzy1z6sxc4554bkmrr86w4vznzmn"))

(define rust-wasm-bindgen-0.2.125
  (crate-source "wasm-bindgen" "0.2.125"
                "06nakz7nfy0ymyp7a27wfbjwx69659i12117hkgddkiv2iwkznwd"))

(define rust-wasm-bindgen-macro-0.2.125
  (crate-source "wasm-bindgen-macro" "0.2.125"
                "0g9w68dwcs4ylm5kxf7schi0kjdfarhc9qlnf8arxc9zn62a28af"))

(define rust-wasm-bindgen-macro-support-0.2.125
  (crate-source "wasm-bindgen-macro-support" "0.2.125"
                "1gayzdx5iwl8gllh7ys79wg9cf4iyasl9hrzzhh5m4xx6nfgvkpy"))

(define rust-wasm-bindgen-shared-0.2.125
  (crate-source "wasm-bindgen-shared" "0.2.125"
                "07w7fy5qa14ys3p8v2p84h98yqinw713smibz9v7apcspd29x4r3"))

(define rust-weak-table-0.3.2
  (crate-source "weak-table" "0.3.2"
                "0ja5zqr1bp5z8wv928y670frnxlj71v6x75g3sg6d6iyaallsgrj"))

(define rust-which-8.0.4
  (crate-source "which" "8.0.4"
                "0j3jskd84vi3icrmcp649iylwsnrdi7ab7pyrnrqzddcshccvms8"))

(define rust-wide-0.7.33
  (crate-source "wide" "0.7.33"
                "00yd2sg83xvfrjjlwndyk49fjx8jlmlrz8byigndig32rf7dmr8c"))

(define rust-winnow-1.0.3
  (crate-source "winnow" "1.0.3"
                "1wajycd3krn6h699vydjv7hm0ll5l31p899qzpk59y2is74y34h5"))

(define rust-wit-bindgen-0.57.1
  (crate-source "wit-bindgen" "0.57.1"
                "0vjk2jb593ri9k1aq4iqs2si9mrw5q46wxnn78im7hm7hx799gqy"))

(define rust-writeable-0.6.3
  (crate-source "writeable" "0.6.3"
                "1i54d13h9bpap2hf13xcry1s4lxh7ap3923g8f3c0grd7c9fbyhz"))

(define rust-xdg-3.0.0
  (crate-source "xdg" "3.0.0"
                "1dc5jpkkylp7z54c4xwxzwxx1jb5cklwfjs5493k9y9d7wik7d1g"))

(define rust-yoke-0.8.3
  (crate-source "yoke" "0.8.3"
                "1xgyj6c2lxj2bp891ynmhws87c6z7yyv2li1v0ss9di40hxf57vh"))

(define rust-yoke-derive-0.8.2
  (crate-source "yoke-derive" "0.8.2"
                "13l5y5sz4lqm7rmyakjbh6vwgikxiql51xfff9hq2j485hk4r16y"))

(define rust-zerocopy-0.8.52
  (crate-source "zerocopy" "0.8.52"
                "0gv563swc1yn3k8w3wjj07a8q293rkx99nfp3a25vzzmbycj446f"))

(define rust-zerocopy-derive-0.8.52
  (crate-source "zerocopy-derive" "0.8.52"
                "0c3rhsh4sd9kdym4z55zprybjkydy9y2gvw75d72aapcfa5z7rqs"))

(define rust-zerofrom-0.1.8
  (crate-source "zerofrom" "0.1.8"
                "0wjjdj7gdmd0iq91gzkxl7dlv0nhkk80l4bmdpzh3a1yh48mmh0f"))

(define rust-zerofrom-derive-0.1.7
  (crate-source "zerofrom-derive" "0.1.7"
                "18c4wsnznhdxx6m80piil1lbyszdiwsshgjrybqcm4b6qic22lqi"))

(define rust-zerotrie-0.2.4
  (crate-source "zerotrie" "0.2.4"
                "1gr0pkcn3qsr6in6iixqyp0vbzwf2j1jzyvh7yl2yydh3p9m548g"))

(define rust-zerovec-0.11.6
  (crate-source "zerovec" "0.11.6"
                "0fdjsy6b31q9i0d73sl7xjd12xadbwi45lkpfgqnmasrqg5i3ych"))

(define rust-zerovec-derive-0.11.3
  (crate-source "zerovec-derive" "0.11.3"
                "0m85qj92mmfvhjra6ziqky5b1p4kcmp5069k7kfadp5hr8jw8pb2"))

(define rust-zlib-rs-0.6.3
  (crate-source "zlib-rs" "0.6.3"
                "04qmv85amq6sv73bzqgvnlsk9mnrl97rygzf2v4zjcx1807d9qrv"))
(define rust-bitflags-2.13.2
  (crate-source "bitflags" "2.13.2"
                "01hbgjwvid66850fzi76mvn5f2bqycx6sf165ng1kfjqq9bl1v9x"))

(define rust-bytemuck-1.25.2
  (crate-source "bytemuck" "1.25.2"
                "15rp2m7j7kq22s76cbjwmrkd5r8lvacnm0mnrj013cnzka22x0wm"))

(define rust-byteorder-lite-0.1.0
  (crate-source "byteorder-lite" "0.1.0"
                "15alafmz4b9az56z6x7glcbcb6a8bfgyd109qc3bvx07zx4fj7wg"))

(define rust-cfg-if-1.0.5
  (crate-source "cfg-if" "1.0.5"
                "0026j56901nzjraap3da0a8njw42j66zcxnn6s2s9aa5bcblhxjf"))

(define rust-crc32fast-1.5.2
  (crate-source "crc32fast" "1.5.2"
                "0y0f955n2hr5a8rd9nw9sr23nhjc42ddx3bjc47dnlmqssgpk9q1"))

(define rust-flate2-1.1.10
  (crate-source "flate2" "1.1.10"
                "1jvd2cl8j5hyf8imi62y1x7gwzz1hajirni0801yxhds1qp4wqvf"))

(define rust-image-0.25.8
  (crate-source "image" "0.25.8"
                "1rwill018gn2kwzv332kfs72ns0kwwnfxwacbhvk9lk9cwzfp7sj"))

(define rust-image-webp-0.2.4
  (crate-source "image-webp" "0.2.4"
                "1hz814csyi9283vinzlkix6qpnd6hs3fkw7xl6z2zgm4w7rrypjj"))

(define rust-miniz-oxide-0.9.1
  (crate-source "miniz_oxide" "0.9.1"
                "0k2bgjzk2sbsynpsv4wizwxbqp6vs7g08y5anbkrh3l6a15bqgxn"))

(define rust-moxcms-0.7.11
  (crate-source "moxcms" "0.7.11"
                "15qa5znj029i7677l0hdv0lwmjggrg920bhjgs3cjvydb72mg5dc"))

(define rust-pxfm-0.1.30
  (crate-source "pxfm" "0.1.30"
                "1slrnbxd0nc96sny6x50ss1sm9ci0gig0fp1w8mw0pkgm5prapfm"))

(define rust-quick-error-2.0.1
  (crate-source "quick-error" "2.0.1"
                "18z6r2rcjvvf8cn92xjhm2qc3jpd1ljvcbf12zv0k9p565gmb4x9"))

(define rust-simd-adler32-0.3.10
  (crate-source "simd-adler32" "0.3.10"
                "1sny4y2qa5mwyxx5x59ln2p02vsdh92004njlslnx98imjc9489s"))

(define rust-zlib-rs-0.6.8
  (crate-source "zlib-rs" "0.6.8"
                "04j158293bx73kv5pj1i89ai411q7fxc9zwk3wkpqgb9gj7fas5j"))

(define rust-zune-core-0.4.12
  (crate-source "zune-core" "0.4.12"
                "0jj1ra86klzlcj9aha9als9d1dzs7pqv3azs1j3n96822wn3lhiz"))

(define rust-zune-jpeg-0.4.21
  (crate-source "zune-jpeg" "0.4.21"
                "04r7g6y9jp7d4c9bq23rz3gwzlr1dsl7vdk4yly35bc4jf52rki9"))

(define rust-flate2-1.1.2
  (crate-source "flate2" "1.1.2"
                "07abz7v50lkdr5fjw8zaw2v8gm2vbppc0f7nqm8x3v3gb6wpsgaa"))

(define rust-indexmap-2.14.2
  (crate-source "indexmap" "2.14.2"
                "0mf86hbjkkcd82cpq683bblbs0zwa8ndla96ci8p1ji6bl7ijknc"))

(define rust-memchr-2.8.3
  (crate-source "memchr" "2.8.3"
                "161xa63ipfanf8v3nb82xd5hqgydv55nzw59wyngqbz6alfaz2yg"))

(define rust-proc-macro2-1.0.107
  (crate-source "proc-macro2" "1.0.107"
                "1nb6ly8kp65f724kj73ippc7lvydss24sm2vagk6qpklpg4pwplq"))

(define rust-quote-1.0.47
  (crate-source "quote" "1.0.47"
                "00ch0yyzvv6s671ik0kcsbw8nigdaj2g3fr61kcahwx48aqlvgqz"))

(define rust-serde-1.0.229
  (crate-source "serde" "1.0.229"
                "1fp04fq4a79bpm61xz1zy0pbz4kpc7d771zii1k3inmszq55jj21"))

(define rust-serde-core-1.0.229
  (crate-source "serde_core" "1.0.229"
                "0j1ajiha76h3nmd976il9li6975k121xa7jb39ws8n0yqp4s5p37"))

(define rust-serde-derive-1.0.229
  (crate-source "serde_derive" "1.0.229"
                "0j4k63i7h1bikxwz2c89ig0hrwbnl9mz1czn85xx99x5cc9dg9g7"))

(define rust-serde-json-1.0.151
  (crate-source "serde_json" "1.0.151"
                "051zww7lvpw147vvwss1ng6w587qyrkzg75fvj08q2dfrmgbahf8"))

(define rust-syn-3.0.6
  (crate-source "syn" "3.0.6"
                "1vmw7s58rzrs926nv5m06x7qbgswm1aa9iw3s1bj5var47kyi4w5"))

(define rust-toml-1.1.6+spec-1.1.0
  (crate-source "toml" "1.1.6+spec-1.1.0"
                "0sj0g89pyrkm9g5zaaqsdlclr98xf1chvi8jv9qsn4897xa041lj"))

(define rust-toml-parser-1.1.3+spec-1.1.0
  (crate-source "toml_parser" "1.1.3+spec-1.1.0"
                "0mjdvihdkmjd4ykh574xgii71hpxw7ns7h4n4bisqpxrz4faqf0x"))

(define rust-toml-writer-1.1.2+spec-1.1.0
  (crate-source "toml_writer" "1.1.2+spec-1.1.0"
                "1lk6pqf9mac3v1x6282n6a66qx5b18c8f4a23bsd0nk658x3amkx"))

(define rust-unicode-ident-1.0.26
  (crate-source "unicode-ident" "1.0.26"
                "0m3915ipi4zz7isncf5k1dz47ys0nq9j7l4l2n2rm03zaxwg8ifj"))

(define rust-winnow-1.0.4
  (crate-source "winnow" "1.0.4"
                "10fzxipa7lx16172p3aca9j60hzbqgjki2f95kqksd5qywcp7f93"))

(define rust-zmij-1.0.23
  (crate-source "zmij" "1.0.23"
                "06zwri21nnrl34rwinmvbciap8yk1mrl8qfg9pff7lgspc56sri9"))

(define rust-android-system-properties-0.1.6
  (crate-source "android_system_properties" "0.1.6"
                "1g3z4ga15a9022vbgi31qqyb7pgk23saq7xfarn6yslpr54ic8mf"))

(define rust-anyhow-1.0.104
  (crate-source "anyhow" "1.0.104"
                "0w34jjcm02p5g9kvsjr1dvpw0zs2fi7igi6nr414fkm5gz85w2ik"))

(define rust-async-recursion-1.2.0
  (crate-source "async-recursion" "1.2.0"
                "0lg4v61ax9wnfb5b5m11895qddcmq5a6h57cihf6n9mdp89br2jg"))

(define rust-async-trait-0.1.92
  (crate-source "async-trait" "0.1.92"
                "0rqn5iga1hlv2lm8xzav1zhar46jb4dvx89i6kfv93kb53maxxl2"))

(define rust-base64-0.23.1
  (crate-source "base64" "0.23.1"
                "19cdw4vh3d8qndbxjmbf6ddvmpicyddg704b4fjxjlchz7ncs1xc"))

(define rust-blocking-1.7.0
  (crate-source "blocking" "1.7.0"
                "1ykd0gj18r4v4b8r692hds5dsg2w6y9fq4nlxs2l7fbcvwll63m7"))

(define rust-bytes-1.12.1
  (crate-source "bytes" "1.12.1"
                "017z19dpg4f942h051m7bpnzcgng042hhcpd7bmg7bjjqd42lrgw"))

(define rust-cc-1.6.0
  (crate-source "cc" "1.6.0"
                "0c3n82hdi355xa6z9x4zgnpjwsh1szkkcs0zl8q8nl5ggk874j7p"))

(define rust-cfg-aliases-0.1.1
  (crate-source "cfg_aliases" "0.1.1"
                "17p821nc6jm830vzl2lmwz60g3a30hcm33nk6l257i1rjdqw85px"))

(define rust-chrono-tz-0.10.4
  (crate-source "chrono-tz" "0.10.4"
                "1hr6rmdvqwgk748g2f69mnk97fzhdkfzaczvdn0wz4pdjy2rl4x6"))

(define rust-crossbeam-utils-0.8.23
  (crate-source "crossbeam-utils" "0.8.23"
                "1ilan2nw7fvka8hki80fr57a5dgd4mvcsvwq60437j6yvlwyw7m3"))

(define rust-event-listener-5.4.2
  (crate-source "event-listener" "5.4.2"
                "1lk9sv7r07l58jk263s18896l55mx9jv0g1rm4hj2mpi3paas8ss"))

(define rust-fastrand-2.5.0
  (crate-source "fastrand" "2.5.0"
                "08q2r30y62winysimnlpbvw9kiwn0rmdlidqlmzd6z90mv764z6s"))

(define rust-filedescriptor-0.8.3
  (crate-source "filedescriptor" "0.8.3"
                "0bb8qqa9h9sj2mzf09yqxn260qkcqvmhmyrmdjvyxcn94knmh1z4"))

(define rust-find-msvc-tools-0.1.14
  (crate-source "find-msvc-tools" "0.1.14"
                "112ljldlv150fpl8xr2jl5czg51k3kdfn6cy5fqdsvkl14sgpp5f"))

(define rust-futures-core-0.3.34
  (crate-source "futures-core" "0.3.34"
                "0pjgv4fx0np6hrs5sz5a2phabwv0z70yr51v03injbi44bjrkmlj"))

(define rust-futures-io-0.3.34
  (crate-source "futures-io" "0.3.34"
                "1v9z6wj92ra18kpv0xig21hgpzrvcwmcr8fszyzh64yyay0zmh2k"))

(define rust-futures-task-0.3.34
  (crate-source "futures-task" "0.3.34"
                "1zfilqs8nwlfqz4prk7ihvpp5avvzins87ibzlxzq5fhs7ipshfd"))

(define rust-futures-util-0.3.34
  (crate-source "futures-util" "0.3.34"
                "1g3r9ghzq7c2fh34lis43i72xavk9p84npgfwgb5vfpqcwjajl0d"))

(define rust-hermit-abi-0.5.3
  (crate-source "hermit-abi" "0.5.3"
                "115jzi6ixx2nhkzbr2ijj36634agz32n6ilz2rg7vk5s1vb94xg1"))

(define rust-http-1.5.0
  (crate-source "http" "1.5.0"
                "1q4wpz5hb4cf37g3jrdyffrpa6ngidmd9wrfph92fddzprl3b3ci"))

(define rust-js-sys-0.3.106
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.106"
                "1icwmpjw54lb7vg5926k5y4y5jbiih0zxhwgjwnzn475v90xk0vq"))

(define rust-lazy-static-1.5.1
  (crate-source "lazy_static" "1.5.1"
                "1yqaqmp510xw2ldpw88mx9b5s5qj8flb4rw0wd9ks1zpk9j0z1r0"))

(define rust-libc-0.2.190
  (crate-source "libc" "0.2.190"
                "0y5yap4bfp7rfsldcbk9pb5alcgygca5xn1n2pmh181zdpf3spff"))

(define rust-log-0.4.34
  (crate-source "log" "0.4.34"
                "1ihkzn0m33ab79fcl4mkb04n5iwqzbxzyw7l7hazqkffaqzbvy7r"))

(define rust-nix-0.28.0
  (crate-source "nix" "0.28.0"
                "1r0rylax4ycx3iqakwjvaa178jrrwiiwghcw95ndzy72zk25c8db"))

(define rust-phf-0.12.1
  (crate-source "phf" "0.12.1"
                "1dz85g1wshfca83mrq3va9rm9n8qcdjlpv1i3908y5zc9j4p6cli"))

(define rust-phf-shared-0.12.1
  (crate-source "phf_shared" "0.12.1"
                "10cr16wpmbjxd7w6k98sxw9yw3zxnzscybl9jzyq3digi045a006"))

(define rust-portable-pty-0.9.0
  (crate-source "portable-pty" "0.9.0"
                "07k710gj2ixgp4r1lcfxvl2qfyvkjr52vb0zyna2sxfjnfi9d9dl"))

(define rust-ring-0.17.14
  (crate-source "ring" "0.17.14"
                "1dw32gv19ccq4hsx3ribhpdzri1vnrlcfqb2vj41xn4l49n9ws54"))

(define rust-rustix-1.1.5
  (crate-source "rustix" "1.1.5"
                "17b2srw7rcqmrs1shj89g8i3r1447lihv7qrbxvp11j1psxgl7l9"))

(define rust-rustls-0.23.45
  (crate-source "rustls" "0.23.45"
                "0d6n90q52x5cjyxb6bwcnf9hwg6yb31cwr63rk8n5yfjqwqxfh8d"))

(define rust-rustls-pki-types-1.15.1
  (crate-source "rustls-pki-types" "1.15.1"
                "15hakk4pcvr5278cazgw9qf2r7gdg09rg5pivbyd3dbyih12aj9g"))

(define rust-rustls-webpki-0.103.15
  (crate-source "rustls-webpki" "0.103.15"
                "1hhanq3lz384v4nccacnjfwsyy99n3yc6m6iw8kljz8yicfwzhzk"))

(define rust-rustversion-1.0.23
  (crate-source "rustversion" "1.0.23"
                "07z2a843fs80fawwflj9jwn49k9b0bd0dhhbvy0ar69vaxd72m6g"))

(define rust-serde-repr-0.1.21
  (crate-source "serde_repr" "0.1.21"
                "01l987ghc17h1y9cf9xbzmcs77575mbrjf4ca2h70g15vqlicfwd"))

(define rust-serial2-0.2.38
  (crate-source "serial2" "0.2.38"
                "0c07302614zdvb7rfya82mzr7qywq15r4lqc9v71jfvr6ny0js5i"))

(define rust-shared-library-0.1.9
  (crate-source "shared_library" "0.1.9"
                "04fs37kdak051hm524a360978g58ayrcarjsbf54vqps5c7px7js"))

(define rust-siphasher-1.0.4
  (crate-source "siphasher" "1.0.4"
                "0mn28y43123jdpskdn6r9wibmn066f7h30zkkqn88bd6hj8zxx1k"))

(define rust-subtle-2.6.1
  (crate-source "subtle" "2.6.1"
                "14ijxaymghbl1p0wql9cib5zlwiina7kall6w7g89csprkgbvhhk"))

(define rust-syn-2.0.119
  (crate-source "syn" "2.0.119"
                "15vjy620l91a3q4n4f4gzhnflmdr6pnm38v2m6cpk86i8av32a47"))

(define rust-tokio-1.53.2
  (crate-source "tokio" "1.53.2"
                "0i202ksji8q2asvii0adzgi8m0z93z3j7apn62qfh8d6qzy92pz9"))

(define rust-tokio-macros-2.7.2
  (crate-source "tokio-macros" "2.7.2"
                "03kvy2r5gr4zccm4vdx8vvv3q69kbjc1b006rs11aibz74m3lxvq"))

(define rust-toml-edit-0.25.15+spec-1.1.0
  (crate-source "toml_edit" "0.25.15+spec-1.1.0"
                "0556lgzcvgfy16b8sxskr391s6cbfwnb0r4h5i4k6qw5lnaflh0k"))

(define rust-untrusted-0.9.0
  (crate-source "untrusted" "0.9.0"
                "1ha7ib98vkc538x0z60gfn0fc5whqdd85mb87dvisdcaifi6vjwf"))

(define rust-ureq-3.4.2
  (crate-source "ureq" "3.4.2"
                "1z6pmhf27s54f3sn2ja1rnqsrnbnjq2lr5xzpl5nwwmpx45w4yls"))

(define rust-ureq-proto-0.6.4
  (crate-source "ureq-proto" "0.6.4"
                "1gl32l71mdak562scwp66vpsjr894bbbvdk1ix2rwmnarird2vzq"))

(define rust-utf8-zero-0.8.1
  (crate-source "utf8-zero" "0.8.1"
                "0vjsmwd1k2wwlsn1phi7mrcjxn4bv8fzk24caxyaw2slr51s1h5q"))

(define rust-uuid-1.27.0
  (crate-source "uuid" "1.27.0"
                "16h5h6bf5ybh1lj97lcdl41g7fqbiczpavpsb0zf3b63p4v7s9wp"))

(define rust-wasm-bindgen-0.2.129
  (crate-source "wasm-bindgen" "0.2.129"
                "02flhqld01jqb6vbfyx1gb8s78g1pnq2164daxad93y6mhrlzdcv"))

(define rust-wasm-bindgen-macro-0.2.129
  (crate-source "wasm-bindgen-macro" "0.2.129"
                "0dc5xq09sy1v9ns1fhb0cnyqz5p1wcjjvkdmxskj9qhnbg1x0a9f"))

(define rust-wasm-bindgen-macro-support-0.2.129
  (crate-source "wasm-bindgen-macro-support" "0.2.129"
                "1dx6w90f14avmhri7ss9lyz03060g6475r4axy3bm7biqf5ill3g"))

(define rust-wasm-bindgen-shared-0.2.129
  (crate-source "wasm-bindgen-shared" "0.2.129"
                "1ilmp5d3sl8lrq9djhcs90gk66yvk8mgwk4sfrvpvkd75b2wkw13"))

(define rust-webpki-roots-1.0.9
  (crate-source "webpki-roots" "1.0.9"
                "0apja04243wz3vi26pqjg4sq8cqaac66prj490sgb1crlc4rvkbx"))

(define rust-winreg-0.10.1
  (crate-source "winreg" "0.10.1"
                "17c6h02z88ijjba02bnxi5k94q5cz490nf3njh9yypf8fbig9l40"))

(define rust-zbus-5.19.0
  (crate-source "zbus" "5.19.0"
                "01sram5sgwsg3x8mghx77cjbsfa2c10mar7fnzj23d2w0xybxd2x"))

(define rust-zbus-macros-5.19.0
  (crate-source "zbus_macros" "5.19.0"
                "0h4gr26kyhdyn503rgg8h44sjxm8d6n8qbzpd0cdzrmd15fn7419"))

(define rust-zbus-names-4.3.4
  (crate-source "zbus_names" "4.3.4"
                "0kk250s3x1fxpz9fvhdr64ydbacpn8ah23hy021yhlzzlfs8igyq"))

(define rust-zcheapstr-1.1.0
  (crate-source "zcheapstr" "1.1.0"
                "0wwlv70bi2rydvvzfq249q6i51mjx85c4m2wxcx1hra5c18yrbyi"))

(define rust-zeroize-1.9.0
  (crate-source "zeroize" "1.9.0"
                "0kpnij2v1ig6g2mhc0bnci0lrdfdhiq40afbc0fahajqc9jiag71"))

(define rust-zvariant-5.15.0
  (crate-source "zvariant" "5.15.0"
                "0iwihslxshfhalihp6kv7xz7nbv1p3b9sl97hi2izpbcrhklrly1"))

(define rust-zvariant-derive-5.15.0
  (crate-source "zvariant_derive" "5.15.0"
                "15y4z1rkcpvrz7dv7j2rfv8wiq6i8nzifj9pgw6dnlj3kgk5ahc6"))

(define rust-zvariant-utils-4.2.0
  (crate-source "zvariant_utils" "4.2.0"
                "18q80094ci64myzvcp0g2l3c6mnx7b3hsii8lfabc853c51jkl5s"))

(define rust-pkg-config-0.3.34
  (crate-source "pkg-config" "0.3.34"
                "0j05h08nzg0q8rf6lzw7nry0b7kn7x97vc9n4hwrl52fqzxn9d7n"))

(define rust-quick-xml-0.41.0
  (crate-source "quick-xml" "0.41.0"
                "1h9y8zry34r3mxfd5vqfj50vvvzvri4kzbx5d657jkqjalg4aq76"))

(define rust-smallvec-1.16.2
  (crate-source "smallvec" "1.16.2"
                "13iai5hhwyp8z0pbn8r11q4j5956jaxhcbvvf2drm17f1q7myfgr"))

(define rust-wayland-backend-0.3.17
  (crate-source "wayland-backend" "0.3.17"
                "0y50cw56f09cdcsinbbl94naz91xf7iqaj87s4f7py6zmm71pa9q"))

(define rust-wayland-client-0.31.15
  (crate-source "wayland-client" "0.31.15"
                "0ww0d0r6rn2h0sn8ma1f7zvxj40l6930p07j044nvmqshq7nmhz3"))

(define rust-wayland-protocols-0.32.13
  (crate-source "wayland-protocols" "0.32.13"
                "1dn4injzx1lnmacnhl3q60m743lvshxmmy0aabb2xaixvq9wil13"))

(define rust-wayland-protocols-wlr-0.3.9
  (crate-source "wayland-protocols-wlr" "0.3.9"
                "1v3qbg18vsb3i62c6042xhjm7dcflmylzjlhl0w9kks3xmilkngg"))

(define rust-wayland-scanner-0.31.11
  (crate-source "wayland-scanner" "0.31.11"
                "1h0al3271l2w124sxlh77s1kmjg0z24ns2mk1vbnfars3d3313ik"))

(define rust-cc-1.10.0
  (crate-source "cc" "1.10.0"
                "185yfn6np0m5x7hz1q7qf595sqzbbs2vc9dshxhssh1ydvx5bq46"))

(define rust-embedded-io-0.7.1
  (crate-source "embedded-io" "0.7.1"
                "1ivwy30m48mkw6si51wwj7zv6ad1h55p9np1cxz5rdvn8xqsmccy"))

(define rust-find-msvc-tools-0.1.15
  (crate-source "find-msvc-tools" "0.1.15"
                "0j5sh4lb7g8xh6kd67s0vz037ah5hlp9f2rbgbg9f41rqmf92rhw"))

(define rust-goblin-0.10.7
  (crate-source "goblin" "0.10.7"
                "1j542pyn5whjaxlqb6lb3b0sxi67fr5573n1rracm33ilwb2cn0p"))

(define rust-heapless-0.9.3
  (crate-source "heapless" "0.9.3"
                "192s7fnk1mqacc16qr74bc86lqkfqwa5gp6q9s5va5cl7zc4pfi5"))


(define rust-aead-0.6.1
  (crate-source "aead" "0.6.1"
                "16acx2vq8lfwr6v8yhg1q7cggrr8ih41ykp7a3srrbrd3aycywqr"))

(define rust-aes-0.9.3
  (crate-source "aes" "0.9.3"
                "0cpascsyy7mzjmx3q3q0fjz8aqyhcf0slj49dpfc6f4fwxngkw1m"))

(define rust-aes-gcm-0.11.1
  (crate-source "aes-gcm" "0.11.1"
                "13s97pcr35pqcy7mi7ij1bvy4vzpifsrfjm45fv54gy8l0380avz"))

(define rust-assert-json-diff-2.0.2
  (crate-source "assert-json-diff" "2.0.2"
                "04mg3w0rh3schpla51l18362hsirl23q93aisws2irrj32wg5r27"))

(define rust-atk-0.18.2
  (crate-source "atk" "0.18.2"
                "0jw2n5xln62px4dh0hxdzbkbfraznkjakwznwhxrjbh72c9646r4"))

(define rust-atk-sys-0.18.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "atk-sys" "0.18.2"
                "11nh2h3g7s772wb6lmjdsjbwi8rf9i11gvyyp8mpv9qc9dl8pr65"))

(define rust-bit-set-0.5.3
  (crate-source "bit-set" "0.5.3"
                "1wcm9vxi00ma4rcxkl3pzzjli6ihrpn9cfdi0c5b4cvga2mxs007"))

(define rust-bit-vec-0.6.3
  (crate-source "bit-vec" "0.6.3"
                "1ywqjnv60cdh1slhz67psnp422md6jdliji6alq0gmly2xm9p7rl"))

(define rust-block-buffer-0.12.1
  (crate-source "block-buffer" "0.12.1"
                "1ak0cvmxz3yifqmzv6aba9606brsz7d5g3piv5xdcvjsx7dwgxnj"))

(define rust-block-padding-0.4.2
  (crate-source "block-padding" "0.4.2"
                "12q66364a5j80iqsi9jg8c447xp7inavmd1qlkw96kpg4b81s3vi"))

(define rust-by-address-1.2.1
  (crate-source "by_address" "1.2.1"
                "01idmag3lcwnnqrnnyik2gmbrr34drsi97q15ihvcbbidf2kryk4"))

(define rust-cairo-rs-0.18.5
  (crate-source "cairo-rs" "0.18.5"
                "1qjfkcq3mrh3p01nnn71dy3kn99g21xx3j8xcdvzn8ll2pq6x8lc"))

(define rust-cairo-sys-rs-0.18.2
  (crate-source "cairo-sys-rs" "0.18.2"
                "0lfsxl7ylw3phbnwmz3k58j1gnqi6kc2hdc7g3bb7f4hwnl9yp38"))

(define rust-cbc-0.2.1
  (crate-source "cbc" "0.2.1"
                "15l8zvdhfazl994ijjww6b8z0p4a7jrqhb44xc5ixlc8bzpcjbff"))

(define rust-cc-1.2.62
  (crate-source "cc" "1.2.62"
                "164zsxcy2zzvbbh1qpbrsssz8kmria41j4agih47sal3y1cyip51"))

(define rust-cesu8-1.1.0
  (crate-source "cesu8" "1.1.0"
                "0g6q58wa7khxrxcxgnqyi9s1z2cjywwwd3hzr5c55wskhx6s0hvd"))

(define rust-cfg-expr-0.15.8
  (crate-source "cfg-expr" "0.15.8"
                "00lgf717pmf5qd2qsxxzs815v6baqg38d6m5i6wlh235p14asryh"))

(define rust-chacha20-0.10.2
  (crate-source "chacha20" "0.10.2"
                "01hvvbgdmqkcgs2s4f12s9wa5h2gbq05rqvypv61azlwd55mxhv5"))

(define rust-cipher-0.5.2
  (crate-source "cipher" "0.5.2"
                "0v7sic43nmz4rgql62wmxq0z63s80gnmd0w5q1vlhw6djcn2mkz8"))

(define rust-clap-4.6.7
  (crate-source "clap" "4.6.7"
                "0il98y2rfw75984ck59znd4n592p07bxz8yy3a9blddb02rpd25a"))

(define rust-clap-builder-4.6.7
  (crate-source "clap_builder" "4.6.7"
                "0kbhai5rv1vj9r4np52g2b9fmhvy3y82digs9v40c57bgbxrf1zc"))

(define rust-clap-derive-4.6.7
  (crate-source "clap_derive" "4.6.7"
                "1q36bgbkfb9rdz7jcvd0ffv0wwlyw0lg3z6iwdcybm0mjjvm3izr"))

(define rust-cmov-0.5.4
  (crate-source "cmov" "0.5.4"
                "0yh22sqdvcdrfbhvnja4kaq5dyklpb4s70w5r6rplfdw4jna17hc"))

(define rust-colored-3.1.1
  (crate-source "colored" "3.1.1"
                "0d5cpbgvyvmmky199s885s6385ykd75q6qg3d2kcxjxq563ldygs"))

(define rust-combine-4.6.8
  (crate-source "combine" "4.6.8"
                "0ppwzwdmszpan9ybx1myc6ldg5zih2sazf9idckdxrh9gn9j1hyg"))

(define rust-compact-str-0.9.1
  (crate-source "compact_str" "0.9.1"
                "1aq0vx3xnaxf9k8p1pwch5v5av0xj2ddq2av25aa76jd4z1d3zcx"))

(define rust-cookie-0.18.2
  (crate-source "cookie" "0.18.2"
                "11rg5wdxnqy4hfa771zyd1hiw59mb7pg1llnlkg3q73908v3wdqs"))

(define rust-core-foundation-0.10.1
  (crate-source "core-foundation" "0.10.1"
                "1xjns6dqf36rni2x9f47b65grxwdm20kwdg9lhmzdrrkwadcv9mj"))

(define rust-core-graphics-0.25.0
  (crate-source "core-graphics" "0.25.0"
                "15rv1iyx5g9sy36pjf1ib6km93n8dksn2p9crx14h6f30brssjq6"))

(define rust-core-graphics-types-0.2.0
  (crate-source "core-graphics-types" "0.2.0"
                "1sqka1rz84lr3p69i1s6lggnpnznmrw4ngc5q76w9xhky80s2i1x"))

(define rust-cpubits-0.1.1
  (crate-source "cpubits" "0.1.1"
                "1bh6rvanxm00myf1rmnh44hq2jdxn69971c92s4klz0k76f5zf0m"))

(define rust-cpufeatures-0.3.0
  (crate-source "cpufeatures" "0.3.0"
                "00fjhygsqmh4kbxxlb99mcsbspxcai6hjydv4c46pwb67wwl2alb"))

(define rust-crc32fast-1.5.1
  (crate-source "crc32fast" "1.5.1"
                "0l75bfakpwr86wz45gm38lylrpgbssr529fmm6m445qy2rqwi644"))

(define rust-critical-section-1.2.0
  (crate-source "critical-section" "1.2.0"
                "02ylhcykxjc40xrfhk1lwc21jqgz4dbwv3jr49ymw733c51yl3kr"))

(define rust-crossbeam-channel-0.5.17
  (crate-source "crossbeam-channel" "0.5.17"
                "1wcy7y77hw7z5m140114iqxb90gsq062djd9zpkndisvgcrcrc4q"))

(define rust-crypto-common-0.2.2
  (crate-source "crypto-common" "0.2.2"
                "0lql5wjlrjkd3r0w32rwbgqfmgg84ms3h65ldnlckmkc3nb4qvnf"))

(define rust-csscolorparser-0.6.2
  (crate-source "csscolorparser" "0.6.2"
                "1gxh11hajx96mf5sd0az6mfsxdryfqvcfcphny3yfbfscqq7sapb"))

(define rust-cssparser-0.37.0
  (crate-source "cssparser" "0.37.0"
                "165s1d8n9i181ni50fzss99gyiigfmzmwyadn217ivfm06pdm74c"))

(define rust-cssparser-macros-0.7.1
  (crate-source "cssparser-macros" "0.7.1"
                "06lfmf31hi4bbpfx6nmb037b6rrzjmdvwr3a5jrd04mp7ilxwifh"))

(define rust-ctr-0.10.1
  (crate-source "ctr" "0.10.1"
                "088z8sa9aw7ij1sy4hlpxz20jhffnsfiwmsdysb2a29pnb2a3b5s"))

(define rust-ctrlc-3.5.2
  (crate-source "ctrlc" "3.5.2"
                "0qh1lvlr6k58dliqllx1n7mjfwp1mzr607bks3r9m0a5msrgmcg0"))

(define rust-ctutils-0.4.4
  (crate-source "ctutils" "0.4.4"
                "0rf8ilkxw2wywk5kkj7qgnwqaxfnacjjb4919xqxjdxcrii8c88j"))

(define rust-darling-0.20.11
  (crate-source "darling" "0.20.11"
                "1vmlphlrlw4f50z16p4bc9p5qwdni1ba95qmxfrrmzs6dh8lczzw"))

(define rust-darling-0.24.1
  (crate-source "darling" "0.24.1"
                "1v625grpyqddgaslgc0kzha41vzqy91yyg80ra9vjc363f8ga5zd"))

(define rust-darling-core-0.20.11
  (crate-source "darling_core" "0.20.11"
                "0bj1af6xl4ablnqbgn827m43b8fiicgv180749f5cphqdmcvj00d"))

(define rust-darling-core-0.24.1
  (crate-source "darling_core" "0.24.1"
                "1zyxlb9ypzb3pzm0l8jy09x2kvd7x7qd50b1z0caxal5fk7y4dv8"))

(define rust-darling-macro-0.20.11
  (crate-source "darling_macro" "0.20.11"
                "1bbfbc2px6sj1pqqq97bgqn6c8xdnb2fmz66f7f40nrqrcybjd7w"))

(define rust-darling-macro-0.24.1
  (crate-source "darling_macro" "0.24.1"
                "1197l1qqsxssys3nnz58x36nv5kzpbjipsxv6dw2yazh7rf17ira"))

(define rust-dbus-0.9.12
  (crate-source "dbus" "0.9.12"
                "0bmk4bn1r8isjxbl780nkdd7grjq2r7125g3r34l0hwcrh1rzdis"))

(define rust-deltae-0.3.2
  (crate-source "deltae" "0.3.2"
                "1d3hw9hpvicl9x0x34jr2ybjk5g5ym1lhbyz6zj31110gq8zaaap"))

(define rust-digest-0.11.3
  (crate-source "digest" "0.11.3"
                "1hnmhd4rkybr11292w42pz9ppzx1h49glrhqg107k4s1b2xnvpgi"))

(define rust-dirs-7.0.0
  (crate-source "dirs" "7.0.0"
                "13yd3nyg81jrqqk8vlnvdsi5dx31xqghk8sclawqjbn8ncix8mwd"))

(define rust-displaydoc-0.2.5
  (crate-source "displaydoc" "0.2.5"
                "1q0alair462j21iiqwrr21iabkfnb13d6x5w95lkdg21q2xrqdlp"))

(define rust-dlopen2-0.8.2
  (crate-source "dlopen2" "0.8.2"
                "1m647mg11ly4f78z34hcndkk4byn25z876y42pid2rlf2pa5nb2y"))

(define rust-dlopen2-derive-0.4.3
  (crate-source "dlopen2_derive" "0.4.3"
                "13vwwh48rlhb679cy15sxs0ppv3k4rkliv07hwx9k03mhy0vgfqg"))

(define rust-dom-query-0.28.0
  (crate-source "dom_query" "0.28.0"
                "1g1rlvyqfl5v5xbamhjifw1cdyg0srjszqm6333lrsb53skzrigs"))

(define rust-dtoa-1.0.11
  (crate-source "dtoa" "1.0.11"
                "1405jvczpxf1zd3nsvw02r50hr2k6argq6jkgdf04prd9s1g8g2c"))

(define rust-dtoa-short-0.3.5
  (crate-source "dtoa-short" "0.3.5"
                "11rwnkgql5jilsmwxpx6hjzkgyrbdmx1d71s0jyrjqm5nski25fd"))

(define rust-euclid-0.22.14
  (crate-source "euclid" "0.22.14"
                "01ksjl4vb8ms89laswnjpld3z4n6c1s7qlqq0djx3imiwdjm787i"))

(define rust-fallible-iterator-0.3.0
  (crate-source "fallible-iterator" "0.3.0"
                "0ja6l56yka5vn4y4pk6hn88z0bpny7a8k1919aqjzp0j1yhy9k1a"))

(define rust-fallible-streaming-iterator-0.1.9
  (crate-source "fallible-streaming-iterator" "0.1.9"
                "0nj6j26p71bjy8h42x6jahx1hn0ng6mc2miwpgwnp8vnwqf4jq3k"))

(define rust-fancy-regex-0.11.0
  (crate-source "fancy-regex" "0.11.0"
                "18j0mmzfycibhxhhhfja00dxd1vf8x5c28lbry224574h037qpxr"))

(define rust-fast-srgb8-1.0.0
  (crate-source "fast-srgb8" "1.0.0"
                "18g6xwwh4gnkyx1352hnvwagpv0n4y98yp2llm8vyvwxh487abnx"))

(define rust-finl-unicode-1.4.0
  (crate-source "finl_unicode" "1.4.0"
                "1md4j32sa8g6y7q9yphpslhhjdjxig1bczkjp8mxccz5lv1xsi4q"))

(define rust-fixedbitset-0.4.2
  (crate-source "fixedbitset" "0.4.2"
                "101v41amgv5n9h4hcghvrbfk5vrncx1jwm35rn5szv4rk55i7rqc"))

(define rust-foreign-types-macros-0.2.4
  (crate-source "foreign-types-macros" "0.2.4"
                "09aj8wl64pqvm6ix1800khgypdhinwinxhfv7n3yn5b95qc90lga"))

(define rust-form-urlencoded-1.2.2
  (crate-source "form_urlencoded" "1.2.2"
                "1kqzb2qn608rxl3dws04zahcklpplkd5r1vpabwga5l50d2v4k6b"))

(define rust-fs2-0.4.3
  (crate-source "fs2" "0.4.3"
                "04v2hwk7035c088f19mfl5b1lz84gnvv2hv6m935n0hmirszqr4m"))

(define rust-futures-0.3.32
  (crate-source "futures" "0.3.32"
                "0b9q86r5ar18v5xjiyqn7sb8sa32xv98qqnfz779gl7ns7lpw54b"))

(define rust-futures-sink-0.3.32
  (crate-source "futures-sink" "0.3.32"
                "14q8ml7hn5a6gyy9ri236j28kh0svqmrk4gcg0wh26rkazhm95y3"))

(define rust-gdk-0.18.2
  (crate-source "gdk" "0.18.2"
                "14967h4pac5gjyrd47yls4wbicrzhbwnd4ajisfwjyk2ijalbwnr"))

(define rust-gdk-pixbuf-0.18.5
  (crate-source "gdk-pixbuf" "0.18.5"
                "1v7svvl0g7zybndmis5inaqqgi1mvcc6s1n8rkb31f5zn3qzbqah"))

(define rust-gdk-pixbuf-sys-0.18.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk-pixbuf-sys" "0.18.0"
                "1xya543c4ffd2n7aiwwrdxsyc9casdbasafi6ixcknafckm3k61z"))

(define rust-gdk-sys-0.18.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdk-sys" "0.18.2"
                "1xzkl9mdfsj1zja7ikrg3g8rinqsb9nqq64yc5k1xb4lhpri6baw"))

(define rust-gdkwayland-sys-0.18.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdkwayland-sys" "0.18.2"
                "0sgyipcl2k39ybw7mk6mii17ggdgaphva2cz5dbzf8yj0vap200l"))

(define rust-gdkx11-0.18.2
  (crate-source "gdkx11" "0.18.2"
                "1zpvndnqasyk9gfnh8mwkb27gsr70dlkcg1v334bpgji8ghh1aiw"))

(define rust-gdkx11-sys-0.18.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gdkx11-sys" "0.18.2"
                "13a2yjqac7i6bqxkpdjfa5rf33v0v06jdnq12vqjdb01zr2p8bkf"))

(define rust-ghash-0.6.0
  (crate-source "ghash" "0.6.0"
                "1mg8nf20qz3pmf9k2xzb4c2x7c8614hs01vpp4rbfrlvvkaz5v1f"))

(define rust-gio-0.18.4
  (crate-source "gio" "0.18.4"
                "0wsc6mnx057s4ailacg99dwgna38dbqli5x7a6y9rdw75x9qzz6l"))

(define rust-gio-sys-0.18.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gio-sys" "0.18.1"
                "1lip8z35iy9d184x2qwjxlbxi64q9cpayy7v1p5y9xdsa3w6smip"))

(define rust-glib-0.18.5
  (crate-source "glib" "0.18.5"
                "1r8fw0627nmn19bgk3xpmcfngx3wkn7mcpq5a8ma3risx3valg93"))

(define rust-glib-macros-0.18.5
  (crate-source "glib-macros" "0.18.5"
                "1p5cla53fcp195zp0hkqpmnn7iwmkdswhy7xh34002bw8y7j5c0b"))

(define rust-glib-sys-0.18.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "glib-sys" "0.18.1"
                "164qhsfmlzd5mhyxs8123jzbdfldwxbikfpq5cysj3lddbmy4g06"))

(define rust-global-hotkey-0.9.0
  (crate-source "global-hotkey" "0.9.0"
                "0w6sf8qvx86slhqn5dhb9rcncvvlrp11617bw2xg778klmv8rnmd"))

(define rust-gobject-sys-0.18.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gobject-sys" "0.18.0"
                "0i6fhp3m6vs3wkzyc22rk2cqj68qvgddxmpaai34l72da5xi4l08"))

(define rust-gtk-0.18.2
  (crate-source "gtk" "0.18.2"
                "0sjh12mvvcmkz54nn30lb2xrzxagshbz1x2i4xfvshpwgccznmpx"))

(define rust-gtk-sys-0.18.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "gtk-sys" "0.18.2"
                "0524c9mwx5jxkl8pb6q45g2n1kfwajz1isa0vnvkwmar3k1a2acg"))

(define rust-gtk3-macros-0.18.2
  (crate-source "gtk3-macros" "0.18.2"
                "179yszj83hgfxl4h4g2zfbsyn9a2zc5zrp6nzqv0fkzi45dkrzsj"))

(define rust-h2-0.4.16
  (crate-source "h2" "0.4.16"
                "09syqqhvh36b3rwyn8vjhiz597hfki1hcz3hwagb3cs1ifapmwx9"))

(define rust-hmac-0.13.0
  (crate-source "hmac" "0.13.0"
                "0gw6avmix6ah63lf70dapxhml4dlcakl9f2lnm6b0hdf6abvq0v3"))

(define rust-html5ever-0.39.0
  (crate-source "html5ever" "0.39.0"
                "1f5pphabfbywvvf6xy86cc31803182zlp546kshwkk7s0wc7d8a6"))

(define rust-http-1.4.0
  (crate-source "http" "1.4.0"
                "06iind4cwsj1d6q8c2xgq8i2wka4ps74kmws24gsi1bzdlw2mfp3"))

(define rust-http-body-1.0.1
  (crate-source "http-body" "1.0.1"
                "111ir5k2b9ihz5nr9cz7cwm7fnydca7dx4hc7vr16scfzghxrzhy"))

(define rust-http-body-util-0.1.3
  (crate-source "http-body-util" "0.1.3"
                "0jm6jv4gxsnlsi1kzdyffjrj8cfr3zninnxpw73mvkxy4qzdj8dh"))

(define rust-httpdate-1.0.3
  (crate-source "httpdate" "1.0.3"
                "1aa9rd2sac0zhjqh24c9xvir96g188zldkx0hr6dnnlx5904cfyz"))

(define rust-hybrid-array-0.4.14
  (crate-source "hybrid-array" "0.4.14"
                "0srzagwa3b41ildy4x3d7ckng51dj7aprkchnaysfbqm5asi8wbh"))

(define rust-hyper-1.9.0
  (crate-source "hyper" "1.9.0"
                "1jmwbwqcaficskg76kq402gbymbnh2z4v99xwq3l5aa6n8bg16b2"))

(define rust-hyper-rustls-0.27.9
  (crate-source "hyper-rustls" "0.27.9"
                "03vfnsm873wsp1dk0q85nxvk7w6syp8c2m5bcdjcyfgg4786ijik"))

(define rust-hyper-util-0.1.20
  (crate-source "hyper-util" "0.1.20"
                "186zdc58hmm663csmjvrzgkr6jdh93sfmi3q2pxi57gcaqjpqm4n"))

(define rust-icu-normalizer-2.2.0
  (crate-source "icu_normalizer" "2.2.0"
                "1d7krxr0xpc4x9635k1100a24nh0nrc59n65j6yk6gbfkplmwvn5"))

(define rust-icu-normalizer-data-2.2.0
  (crate-source "icu_normalizer_data" "2.2.0"
                "0f5d5d5fhhr9937m2z6z38fzh6agf14z24kwlr6lyczafypf0fys"))

(define rust-ident-case-1.0.1
  (crate-source "ident_case" "1.0.1"
                "0fac21q6pwns8gh1hz3nbq15j8fi441ncl6w4vlnd1cmc55kiq5r"))

(define rust-idna-1.1.0
  (crate-source "idna" "1.1.0"
                "1pp4n7hppm480zcx411dsv9wfibai00wbpgnjj4qj0xa7kr7a21v"))

(define rust-idna-adapter-1.2.2
  (crate-source "idna_adapter" "1.2.2"
                "0557p76l8hj35r9zn1yv7c6x1c0qbrsffmg80n0yy8361ly3fs6b"))

(define rust-inout-0.2.2
  (crate-source "inout" "0.2.2"
                "1iq39s01d3y56j2r6hf75yqhpa7s2ifwr316yzyi0879a9jcwl22"))

(define rust-insta-1.49.0
  (crate-source "insta" "1.49.0"
                "1k91zskbkqjj97rhb7dkpms9py6i6c868frz1g0qcjvy50p3szdn"))

(define rust-instability-0.3.10
  (crate-source "instability" "0.3.10"
                "170dsap2il7fpx85dylb4q979czrbj77ay6v77vpvvpgdqcv0y37"))

(define rust-ipnet-2.12.0
  (crate-source "ipnet" "2.12.0"
                "1qpq2y0asyv0jppw7zww9y96fpnpinwap8a0phhqqgyy3znnz3yr"))

(define rust-itertools-0.14.0
  (crate-source "itertools" "0.14.0"
                "118j6l1vs2mx65dqhwyssbrxpawa90886m3mzafdvyip41w2q69b"))

(define rust-javascriptcore-rs-1.1.2
  (crate-source "javascriptcore-rs" "1.1.2"
                "1k3z4pmg46znxfmjqvx63d5zr9vdj070f97wgajzp3yfzzlp2mna"))

(define rust-javascriptcore-rs-sys-1.1.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "javascriptcore-rs-sys" "1.1.1"
                "092igagxm561lx65sin2z18jpxzyg0288cfzcrdvg97z2j6yf6xg"))

(define rust-jni-0.21.1
  (crate-source "jni" "0.21.1"
                "15wczfkr2r45slsljby12ymf2hij8wi5b104ghck9byjnwmsm1qs"))

(define rust-js-sys-0.3.99
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.99"
                "04azrzsz91gr5s3z0ij36lz0kj9ry4lw3jz0mmbiwb251rsc8aql"))

(define rust-kasuari-0.4.12
  (crate-source "kasuari" "0.4.12"
                "1688q59qh1mxa28k00lnddn73mh3jcdmj3yrc7l99k23c5yhbrdx"))

(define rust-keyboard-types-0.8.3
  (crate-source "keyboard-types" "0.8.3"
                "13dj6jsk4rr4kqghlxyr3ql7ajfrg65awc1h4c21mris80xqbghg"))

(define rust-lab-0.11.0
  (crate-source "lab" "0.11.0"
                "13ymsn5cwl5i9pmp5mfmbap7q688dcp9a17q82crkvb784yifdmz"))

(define rust-libappindicator-0.9.0
  (crate-source "libappindicator" "0.9.0"
                "02nwjmm5qqbkvzbz4j1dd50xs0ywr0i2l2scwmxcqs680yb9nn03"))

(define rust-libappindicator-sys-0.9.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libappindicator-sys" "0.9.0"
                "1bsw2mcxil3zm4zzdir76i7xnaqaq30cd9qpviccrvdb70hwb7kf"))

(define rust-libdbus-sys-0.2.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libdbus-sys" "0.2.7"
                "0hzhq0dz6lfzmhsym9m95cfhjzrwq74qdg85xkpg2012sj4lg31j"))

(define rust-libsqlite3-sys-0.39.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libsqlite3-sys" "0.39.1"
                "1cx2z7q7rqacffszy2qsv0vlcxmwdkwhcg23gg80a9xrhwdz198l"))

(define rust-line-clipping-0.3.7
  (crate-source "line-clipping" "0.3.7"
                "1y19rla4ivdwagf0y4yahvb8jzsddj3jcb8r0xa8n9i3fvsfhl1z"))

(define rust-lru-0.18.2
  (crate-source "lru" "0.18.2"
                "02nrs4r8jdnmrm08ab6pvsy87gimklr9ks77jm6v5rm79fdjybsx"))

(define rust-lru-slab-0.1.2
  (crate-source "lru-slab" "0.1.2"
                "0m2139k466qj3bnpk66bwivgcx3z88qkxvlzk70vd65jq373jaqi"))

(define rust-mac-address-1.1.8
  (crate-source "mac_address" "1.1.8"
                "00r3n18mxglq1dzshnm0vxk1fgsp3c2hd08w6hfcqdp8ymmv5bn0"))

(define rust-markup5ever-0.39.0
  (crate-source "markup5ever" "0.39.0"
                "1pjpjwzlsv03ljpprq3swamfj8ipv6kl2nvfdzjlww2zxj3xj8ki"))

(define rust-memmem-0.1.1
  (crate-source "memmem" "0.1.1"
                "05ccifqgxdfxk6yls41ljabcccsz3jz6549l1h3cwi17kr494jm6"))

(define rust-mio-1.2.0
  (crate-source "mio" "1.2.0"
                "1hanrh4fwsfkdqdaqfidz48zz1wdix23zwn3r2x78am0garfbdsh"))

(define rust-mockito-1.7.2
  (crate-source "mockito" "1.7.2"
                "1h4jpghvhgcyybqbvhxkzjpq4sjl49n4q9vbqk7ikarcf4c0d0lh"))

(define rust-muda-0.21.1
  (crate-source "muda" "0.21.1"
                "17mq8ksd5q9fcabmn21w8rwj5i7ivpcypqkzhckaz0q7r8600yws"))

(define rust-new-debug-unreachable-1.0.6
  (crate-source "new_debug_unreachable" "1.0.6"
                "11phpf1mjxq6khk91yzcbd3ympm78m3ivl7xg6lg2c0lf66fy3k5"))

(define rust-nix-0.29.0
  (crate-source "nix" "0.29.0"
                "0ikvn7s9r2lrfdm3mx1h7nbfjvcc6s9vxdzw7j5xfkd2qdnp9qki"))

(define rust-nix-0.31.3
  (crate-source "nix" "0.31.3"
                "0gbwnjfny9rq9hl5bz4ry520n9rnfknna4bg88n66f7zx3yx486g"))

(define rust-num-conv-0.2.2
  (crate-source "num-conv" "0.2.2"
                "0hg4f9bwmy7cwpxdkm165dmkfc8jhkkayci234jsmi5ssb33j5sj"))

(define rust-num-derive-0.4.2
  (crate-source "num-derive" "0.4.2"
                "00p2am9ma8jgd2v6xpsz621wc7wbn1yqi71g15gc3h67m7qmafgd"))

(define rust-num-threads-0.1.7
  (crate-source "num_threads" "0.1.7"
                "1ngajbmhrgyhzrlc4d5ga9ych1vrfcvfsiqz6zv0h2dpr2wrhwsw"))

(define rust-objc2-0.6.5
  (crate-source "objc2" "0.6.5"
                "1y41g7xhc3idzymsgr5vh414xzl43jp5cs39ayaaxpv78yyrp108"))

(define rust-objc2-app-kit-0.3.2
  (crate-source "objc2-app-kit" "0.3.2"
                "132ijwni8lsi8phq7wnmialkxp46zx998fns3zq5np0ya1mr77nl"))

(define rust-objc2-cloud-kit-0.3.2
  (crate-source "objc2-cloud-kit" "0.3.2"
                "0714xrydi9wvh25s2110sjfpx9mv4xs9p4ys71q8fhxvh3c79bbk"))

(define rust-objc2-core-data-0.3.2
  (crate-source "objc2-core-data" "0.3.2"
                "1ylqsa6hpma7k4090pkil8b7c0i8dcxnh46zwhnfidgv7rjjlh0b"))

(define rust-objc2-core-graphics-0.3.2
  (crate-source "objc2-core-graphics" "0.3.2"
                "01x8413pxq0m5rwidlaczni8v5cz9dc3xqzq8l9zlpl9cv8cj8p0"))

(define rust-objc2-core-image-0.3.2
  (crate-source "objc2-core-image" "0.3.2"
                "01phi7cx2k32a8x45qr0y1623l2b8gg764c6isgj15rbinrn7mg5"))

(define rust-objc2-core-location-0.3.2
  (crate-source "objc2-core-location" "0.3.2"
                "02908pp1knq64wjq07zd6q2z77qppdpd7l2z0by77jabw8a74d6a"))

(define rust-objc2-core-text-0.3.2
  (crate-source "objc2-core-text" "0.3.2"
                "0bfrzqxhgh4y1imk1bb9g0v28g0frigls6hnc942npfj93xhvphc"))

(define rust-objc2-core-video-0.3.2
  (crate-source "objc2-core-video" "0.3.2"
                "19j1a7f863gh30nq03w70x1js3f3vdg3wp4azllky8vkvzqwl9fl"))

(define rust-objc2-exception-helper-0.1.1
  (crate-source "objc2-exception-helper" "0.1.1"
                "12nrg6fhhp2rzmnym6s37h7w9v9sa9wbaixvfsq3axrdnzxwb8f7"))

(define rust-objc2-io-surface-0.3.2
  (crate-source "objc2-io-surface" "0.3.2"
                "07fqx4fmwydf2arrc4xs4awv7zyzzxh60fyqdfmrpm9n148qh1qq"))

(define rust-objc2-metal-0.3.2
  (crate-source "objc2-metal" "0.3.2"
                "1527q158b8kagmdzlmvg782s5m7h15j62x1d2ps0ml0hd9vmy4m0"))

(define rust-objc2-quartz-core-0.3.2
  (crate-source "objc2-quartz-core" "0.3.2"
                "07vzaf6y1lk7zygkgvpp23mm19ipdm9yq8af22gvywdkaa23bhcn"))

(define rust-objc2-ui-kit-0.3.2
  (crate-source "objc2-ui-kit" "0.3.2"
                "08mbgqg8pffclyxpz2lr8r1fv8wn2i4m1k6bk1s5fvy06f766zfq"))

(define rust-objc2-user-notifications-0.3.2
  (crate-source "objc2-user-notifications" "0.3.2"
                "0gk1frfj875pkbz3ncs8swvjgdipz3vwq5l42vd3rxzypf615ycx"))

(define rust-objc2-web-kit-0.3.2
  (crate-source "objc2-web-kit" "0.3.2"
                "0zqyflb4r2igpg5s48fmjbcajikvdbwpm7fzf3s3qhqck2msmrdj"))

(define rust-openssl-probe-0.2.1
  (crate-source "openssl-probe" "0.2.1"
                "1gpwpb7smfhkscwvbri8xzbab39wcnby1jgz1s49vf1aqgsdx1vw"))

(define rust-ordered-float-4.6.0
  (crate-source "ordered-float" "4.6.0"
                "0ldrcgilsiijd141vw51fbkziqmh5fpllil3ydhirjm67wdixdvv"))

(define rust-palette-0.7.6
  (crate-source "palette" "0.7.6"
                "1rmn02mv6cb112504qyg7pyfa83c08hxpk5sw7jc5v659hc73gsc"))

(define rust-palette-derive-0.7.6
  (crate-source "palette_derive" "0.7.6"
                "0c0xhpk1nqyq4jr2m8xnka7w47vqzc7m2vq9ih8wxyjv02phs0zm"))

(define rust-pango-0.18.3
  (crate-source "pango" "0.18.3"
                "1r5ygq7036sv7w32kp8yxr6vgggd54iaavh3yckanmq4xg0px8kw"))

(define rust-pango-sys-0.18.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "pango-sys" "0.18.0"
                "1iaxalcaaj59cl9n10svh4g50v8jrc1a36kd7n9yahx8j7ikfrs3"))

(define rust-pastey-0.2.3
  (crate-source "pastey" "0.2.3"
                "1d1mk45ma9w54ppws8x096q96qhqirxmj9j3hchj7fmi1087zrif"))

(define rust-pbkdf2-0.13.0
  (crate-source "pbkdf2" "0.13.0"
                "0a867f3jikfwjfni9fhmrjhdb7qcjzjd917lk96m5gy5p3784b8i"))

(define rust-pest-2.8.6
  (crate-source "pest" "2.8.6"
                "0qm6kpqsbn2p6vkd7v4j3g7wsjby2ip6di1h6kx7vlq921h8r170"))

(define rust-pest-derive-2.8.6
  (crate-source "pest_derive" "2.8.6"
                "0xzysvcyfs0pkn2801rg811y83jx2rvpqnjxs47c3ri1xbqqdx0i"))

(define rust-pest-generator-2.8.6
  (crate-source "pest_generator" "2.8.6"
                "0kzrcik2ww0qh84jlv8xqc0zmzgl3xy41vf1cfli1chkgdjc8h40"))

(define rust-pest-meta-2.8.6
  (crate-source "pest_meta" "2.8.6"
                "08126skq2lxysinp6v917niszhnnh6d6a9kg2i0a28b0sdlmr0c9"))

(define rust-phf-0.11.3
  (crate-source "phf" "0.11.3"
                "0y6hxp1d48rx2434wgi5g8j1pr8s5jja29ha2b65435fh057imhz"))

(define rust-phf-codegen-0.11.3
  (crate-source "phf_codegen" "0.11.3"
                "0si1n6zr93kzjs3wah04ikw8z6npsr39jw4dam8yi9czg2609y5f"))

(define rust-phf-codegen-0.13.1
  (crate-source "phf_codegen" "0.13.1"
                "1qfnsl2hiny0yg4lwn888xla5iwccszgxnx8dhbwl6s2h2fpzaj9"))

(define rust-phf-generator-0.11.3
  (crate-source "phf_generator" "0.11.3"
                "0gc4np7s91ynrgw73s2i7iakhb4lzdv1gcyx7yhlc0n214a2701w"))

(define rust-phf-macros-0.11.3
  (crate-source "phf_macros" "0.11.3"
                "05kjfbyb439344rhmlzzw0f9bwk9fp95mmw56zs7yfn1552c0jpq"))

(define rust-phf-shared-0.11.3
  (crate-source "phf_shared" "0.11.3"
                "1rallyvh28jqd9i916gk5gk2igdmzlgvv5q0l3xbf3m6y8pbrsk7"))

(define rust-polyval-0.7.3
  (crate-source "polyval" "0.7.3"
                "1ka97nwkh4a1rjza473h9mv98yl4rqhs62jdahmcpcpj67b33yph"))

(define rust-precomputed-hash-0.1.1
  (crate-source "precomputed-hash" "0.1.1"
                "075k9bfy39jhs53cb2fpb9klfakx2glxnf28zdw08ws6lgpq6lwj"))

(define rust-proc-macro-crate-1.3.1
  (crate-source "proc-macro-crate" "1.3.1"
                "069r1k56bvgk0f58dm5swlssfcp79im230affwk6d9ck20g04k3z"))

(define rust-proc-macro-crate-2.0.2
  (crate-source "proc-macro-crate" "2.0.2"
                "092x5acqnic14cw6vacqap5kgknq3jn4c6jij9zi6j85839jc3xh"))

(define rust-quinn-0.11.9
  (crate-source "quinn" "0.11.9"
                "086gzj666dr3slmlynkvxlndy28hahgl361d6bf93hk3i6ahmqmr"))

(define rust-quinn-proto-0.11.18
  (crate-source "quinn-proto" "0.11.18"
                "1z6931x1gn4mkhrbbbww3syb4c8awc229bqz5x7lyqvnw6ynsx59"))

(define rust-quinn-udp-0.5.14
  (crate-source "quinn-udp" "0.5.14"
                "1gacawr17a2zkyri0r3m0lc9spzmxbq1by3ilyb8v2mdvjhcdpmd"))

(define rust-rand-0.10.3
  (crate-source "rand" "0.10.3"
                "1bxlhj4m9zrgfgk1yirf0nny86izrngscydfx9w387n9rfbgpjb5"))

(define rust-rand-pcg-0.10.2
  (crate-source "rand_pcg" "0.10.2"
                "0sp817pvwb3d2nxb1ww1y0f8x3kc4w198j2iqvs742hwgq9z986a"))

(define rust-ratatui-0.30.2
  (crate-source "ratatui" "0.30.2"
                "0zfmk50bl3ahjjq0z55h5rmx5njrvks20p80lb9cl6sy5h5blx1j"))

(define rust-ratatui-bubbletea-components-0.2.0
  (crate-source "ratatui-bubbletea-components" "0.2.0"
                "0yz600mh4vfz54nis4k4klmxqx2xm04nsb9b0vfjqa28hv6b6qqy"))

(define rust-ratatui-bubbletea-theme-0.2.0
  (crate-source "ratatui-bubbletea-theme" "0.2.0"
                "051r9bgkmgr235p43fpx78dcqxgljrvq5kmjvq63j81f65g21q8p"))

(define rust-ratatui-core-0.1.2
  (crate-source "ratatui-core" "0.1.2"
                "1727mqrvy80hmg5nbf0dwh68rrlnmsi76mqzkn08mqn86g27bcfb"))

(define rust-ratatui-crossterm-0.1.2
  (crate-source "ratatui-crossterm" "0.1.2"
                "1w59rh1xdvd133yxnqskxcjnf9lp2j3b8h6y4cy21a76n2iq8xan"))

(define rust-ratatui-macros-0.7.2
  (crate-source "ratatui-macros" "0.7.2"
                "056q80hzmwamv511xfygzcw0rq97hh3ypq389lza963lma6wczgd"))

(define rust-ratatui-termina-0.1.0
  (crate-source "ratatui-termina" "0.1.0"
                "1hj35knwflynqim7sxdbaarqda0f51m3hbnrb6kmgw36kqnr3gy0"))

(define rust-ratatui-termwiz-0.1.2
  (crate-source "ratatui-termwiz" "0.1.2"
                "0xz95i63n7nafpsk6jbm56h65w5dwd7j4x6bsra40x5ph01kxw7s"))

(define rust-ratatui-widgets-0.3.2
  (crate-source "ratatui-widgets" "0.3.2"
                "1l87cjanipc1bzwza1mywfn23wbzfrh3pnbpc8vwlc4irjdx3qv6"))

(define rust-ref-cast-1.0.27
  (crate-source "ref-cast" "1.0.27"
                "1hv5sf0j7b65gz2g57c3wp0fzr5r3807dywf6fap455lwjs0yi3y"))

(define rust-ref-cast-impl-1.0.27
  (crate-source "ref-cast-impl" "1.0.27"
                "0fnzgkvddgl9xs3884x5ypi9rd0dgc1p5vd1k4b74lw49ybdiv4j"))

(define rust-reqwest-0.12.28
  (crate-source "reqwest" "0.12.28"
                "0iqidijghgqbzl3bjg5hb4zmigwa4r612bgi0yiq0c90b6jkrpgd"))

(define rust-rmcp-3.8.0
  (crate-source "rmcp" "3.8.0"
                "07wdhyif6shi746f929ljw26hdbcs48m005zcfh3x1w6a60ibgpq"))

(define rust-rmcp-macros-3.8.0
  (crate-source "rmcp-macros" "3.8.0"
                "0fdqvfkm0la5ryfcb5nrlidp9cp6k84p5kqk6a5mkxd5akh4h1wb"))

(define rust-rusqlite-0.41.1
  (crate-source "rusqlite" "0.41.1"
                "1555j4yrk3zc9dm68036i4c8vd0qpq2xz1k51895w4q66mpvm6ys"))

(define rust-rustix-1.1.6
  (crate-source "rustix" "1.1.6"
                "1ajqv2zxmfms30hhvp5bdzpixn5xqnz7s871vpa56h99wm16grz5"))

(define rust-rustls-0.23.46
  (crate-source "rustls" "0.23.46"
                "1pwg7i8drr70374amj96952cils9mpwyijd5rx1mqdp9q3c3pqa8"))

(define rust-rustls-native-certs-0.8.4
  (crate-source "rustls-native-certs" "0.8.4"
                "0kgazl8zc1sv63qg179bz96ilzh56lzfa5k92ji7d265f4kibdfs"))

(define rust-rustls-pki-types-1.14.1
  (crate-source "rustls-pki-types" "1.14.1"
                "1a9pr54y0f3qr97bxpd3ahjldq0gqdld0h799xbnwdzbwxx1k9rh"))

(define rust-rustls-webpki-0.103.16
  (crate-source "rustls-webpki" "0.103.16"
                "10djm2f00xzi5qlbcfqjhhn2smk2h9aw8b4l74qncz4xsfvb2hs4"))

(define rust-schannel-0.1.29
  (crate-source "schannel" "0.1.29"
                "0ffrzz5vf2s3gnzvphgb5gg8fqifvryl07qcf7q3x1scj3jbghci"))

(define rust-schemars-1.2.3
  (crate-source "schemars" "1.2.3"
                "0vnzz8smh3ixzy297898mwzfx0r5aadz2vxsbafwlxsaywk8hl5b"))

(define rust-schemars-derive-1.2.3
  (crate-source "schemars_derive" "1.2.3"
                "0sgwpzi91y6ibw7ns4wpqzgm9ddnmi7q8ia62am62zgsjhhakhz1"))

(define rust-security-framework-3.7.0
  (crate-source "security-framework" "3.7.0"
                "07fd0j29j8yczb3hd430vwz784lx9knb5xwbvqna1nbkbivvrx5p"))

(define rust-security-framework-sys-2.17.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "security-framework-sys" "2.17.0"
                "1qr0w0y9iwvmv3hwg653q1igngnc5b74xcf0679cbv23z0fnkqkc"))

(define rust-selectors-0.38.0
  (crate-source "selectors" "0.38.0"
                "0k8ik7p8rwlvrl51krh6wxx3jms3hwxkn8lblaw2fa4ik31a3pwa"))

(define rust-serde-derive-internals-0.30.0
  (crate-source "serde_derive_internals" "0.30.0"
                "1gd9n45na7n79nr54ghfl79rygkbzw2ybk3wyr6nlp83rry16lpq"))

(define rust-serde-json-1.0.154
  (crate-source "serde_json" "1.0.154"
                "1mjby21g8fxhrsfp73yz8wg6n2f4h23ah0nczds409l53f5wrsg7"))

(define rust-serde-spanned-0.6.9
  (crate-source "serde_spanned" "0.6.9"
                "18vmxq6qfrm110caszxrzibjhy2s54n1g5w1bshxq9kjmz7y0hdz"))

(define rust-serde-urlencoded-0.7.1
  (crate-source "serde_urlencoded" "0.7.1"
                "1zgklbdaysj3230xivihs30qi5vkhigg323a9m62k8jwf4a1qjfk"))

(define rust-servo-arc-0.4.3
  (crate-source "servo_arc" "0.4.3"
                "0c2rl0r9x4kbppwlcrd5bnwds612na179im7kb37vqadncxbh3qp"))

(define rust-sha1-0.11.0
  (crate-source "sha1" "0.11.0"
                "05025pf8d8zr2qq5xyh5m3wqls1fn7813gz1mfs7551mk724rk5a"))

(define rust-sha2-0.11.1
  (crate-source "sha2" "0.11.1"
                "06ddr559jvwx17d7847l6i1g4hrlwy39j0yimjwwfskxxfdhdms7"))

(define rust-siphasher-1.0.3
  (crate-source "siphasher" "1.0.3"
                "0jg6l9xyzca5vy4h6gf8r6p4kk84g98fk95pzig1kq6cr4z8grcf"))

(define rust-socket2-0.6.3
  (crate-source "socket2" "0.6.3"
                "0gkjjcyn69hqhhlh5kl8byk5m0d7hyrp2aqwzbs3d33q208nwxis"))

(define rust-soup3-0.5.0
  (crate-source "soup3" "0.5.0"
                "17sgrkvx5jy6r6pyyhh8cl5mrm96rf0yfl3lqypm24pk815947s7"))

(define rust-soup3-sys-0.5.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "soup3-sys" "0.5.0"
                "09vcp2m0hcddjqsv979d4jnribxp1pvipgjyy4j2z8c0lr88kgky"))

(define rust-string-cache-0.9.0
  (crate-source "string_cache" "0.9.0"
                "008rwf8gd1xhwr523r5zzzgypgkfmrz6l3wwh7r2k9w5qzw9d1d1"))

(define rust-string-cache-codegen-0.6.1
  (crate-source "string_cache_codegen" "0.6.1"
                "0scvya8dsfard2r8m7pb2cjnar312jc9g165fsghacdjdpj3amjq"))

(define rust-syn-3.0.3
  (crate-source "syn" "3.0.3"
                "18srnql3cd39j9q6hf1az02p67rlr1rf6njx9zx4vxj9i3jvmsak"))

(define rust-sync-wrapper-1.0.2
  (crate-source "sync_wrapper" "1.0.2"
                "0qvjyasd6w18mjg5xlaq5jgy84jsjfsvmnn12c13gypxbv75dwhb"))

(define rust-system-deps-6.2.2
  (crate-source "system-deps" "6.2.2"
                "0j93ryw031n3h8b0nfpj5xwh3ify636xmv8kxianvlyyipmkbrd3"))

(define rust-tao-0.37.2
  (crate-source "tao" "0.37.2"
                "0j1mpk5fqjcw3r3gab1h1phy2l70d6ifn5nqx1m14db4zq37nxym"))

(define rust-tao-macros-0.1.4
  (crate-source "tao-macros" "0.1.4"
                "0jaqpl3n2xsdwzrabcnyg30wjspi8mcpk8ahc7d4am8mk5nynzjz"))

(define rust-target-lexicon-0.12.16
  (crate-source "target-lexicon" "0.12.16"
                "1cg3bnx1gdkdr5hac1hzxy64fhw4g7dqkd0n3dxy5lfngpr1mi31"))

(define rust-tendril-0.5.1
  (crate-source "tendril" "0.5.1"
                "023v11ndbqc2181v1p1dfwggvsjw9zm17hdikg856fjvkiq59vaz"))

(define rust-terminfo-0.9.0
  (crate-source "terminfo" "0.9.0"
                "0qp6rrzkxcg08vjzsim2bw7mid3vi29mizrg70dzbycj0q7q3snl"))

(define rust-termios-0.3.3
  (crate-source "termios" "0.3.3"
                "0sxcs0g00538jqh5xbdqakkzijadr8nj7zmip0c7jz3k83vmn721"))

(define rust-termwiz-0.23.3
  (crate-source "termwiz" "0.23.3"
                "1xzq6l7rx285ax57dz8gdh44kp1790x0knvfynmimgfc89rb6xj6"))

(define rust-thiserror-2.0.21
  (crate-source "thiserror" "2.0.21"
                "17hq1lh5dyr3bkc7zzjrbrp4qgkvhc48kgq1n5fdxkindaw2rr89"))

(define rust-thiserror-impl-2.0.21
  (crate-source "thiserror-impl" "2.0.21"
                "0945n8agp7kg6n6b35yyjb4g5xv2q22vrw15h6jj1nw76a99flgy"))

(define rust-tokio-1.54.1
  (crate-source "tokio" "1.54.1"
                "18wn0c3yvy6ld8yis0fw6rqkc4rwnmv5mav4fan6zljqa8jx6bxm"))

(define rust-tokio-rustls-0.26.4
  (crate-source "tokio-rustls" "0.26.4"
                "0qggwknz9w4bbsv1z158hlnpkm97j3w8v31586jipn99byaala8p"))

(define rust-tokio-util-0.7.18
  (crate-source "tokio-util" "0.7.18"
                "1600rd47pylwn7cap1k7s5nvdaa9j7w8kqigzp1qy7mh0p4cxscs"))

(define rust-toml-0.8.2
  (crate-source "toml" "0.8.2"
                "0g9ysjaqvm2mv8q85xpqfn7hi710hj24sd56k49wyddvvyq8lp8q"))

(define rust-toml-datetime-0.6.3
  (crate-source "toml_datetime" "0.6.3"
                "0jsy7v8bdvmzsci6imj8fzgd255fmy5fzp6zsri14yrry7i77nkw"))

(define rust-toml-edit-0.19.15
  (crate-source "toml_edit" "0.19.15"
                "08bl7rp5g6jwmfpad9s8jpw8wjrciadpnbaswgywpr9hv9qbfnqv"))

(define rust-toml-edit-0.20.2
  (crate-source "toml_edit" "0.20.2"
                "0f7k5svmxw98fhi28jpcyv7ldr2s3c867pjbji65bdxjpd44svir"))

(define rust-tower-0.5.3
  (crate-source "tower" "0.5.3"
                "1m5i3a2z1sgs8nnz1hgfq2nr4clpdmizlp1d9qsg358ma5iyzrgb"))

(define rust-tower-http-0.6.11
  (crate-source "tower-http" "0.6.11"
                "0h08wjgs3hwnq11iwwzlmnabn1h4cl0fzd48svaccvqffkiggz2c"))

(define rust-tower-layer-0.3.3
  (crate-source "tower-layer" "0.3.3"
                "03kq92fdzxin51w8iqix06dcfgydyvx7yr6izjq0p626v9n2l70j"))

(define rust-tower-service-0.3.3
  (crate-source "tower-service" "0.3.3"
                "1hzfkvkci33ra94xjx64vv3pp0sq346w06fpkcdwjcid7zhvdycd"))

(define rust-tray-icon-0.26.1
  (crate-source "tray-icon" "0.26.1"
                "1jfxsqzlp63ljf5y909b9mrggmpzywpjl0zhv3fp95fgis2wap2g"))

(define rust-try-lock-0.2.5
  (crate-source "try-lock" "0.2.5"
                "0jqijrrvm1pyq34zn1jmy2vihd4jcrjlvsh4alkjahhssjnsn8g4"))

(define rust-ucd-trie-0.1.7
  (crate-source "ucd-trie" "0.1.7"
                "0wc9p07sqwz320848i52nvyjvpsxkx3kv5bfbmm6s35809fdk5i8"))

(define rust-unicode-truncate-2.0.1
  (crate-source "unicode-truncate" "2.0.1"
                "19g9af5v0a8xaigqbs9hi9csxkg1fff07ycilvwfaqw64fhq1cqn"))

(define rust-unicode-width-0.2.3
  (crate-source "unicode-width" "0.2.3"
                "0mymrsdklcgys4fndds2h2hasij36gyalcqy4nghb4k9hxqq8wfa"))

(define rust-universal-hash-0.6.1
  (crate-source "universal-hash" "0.6.1"
                "15la0jq3jpzvabwx3kdrk34spylgfd85r9n4pvh84cvm2bf7p67l"))

(define rust-url-2.5.8
  (crate-source "url" "2.5.8"
                "1v8f7nx3hpr1qh76if0a04sj08k86amsq4h8cvpw6wvk76jahrzz"))

(define rust-uuid-1.23.2
  (crate-source "uuid" "1.23.2"
                "1xy942s4z0bi8p3441wvd4ry3hx6ry1c7s6fgrr38462xqybhn6j"))

(define rust-vtparse-0.6.2
  (crate-source "vtparse" "0.6.2"
                "1l5yz9650zhkaffxn28cvfys7plcw2wd6drajyf41pshn37jm6vd"))

(define rust-want-0.3.1
  (crate-source "want" "0.3.1"
                "03hbfrnvqqdchb5kgxyavb9jabwza0dmh2vw5kg0dq8rxl57d9xz"))

(define rust-wasm-bindgen-0.2.122
  (crate-source "wasm-bindgen" "0.2.122"
                "02flix96brsb2r1i3grnikii302iqpdm337kl3xv5lklz5v4bl1y"))

(define rust-wasm-bindgen-futures-0.4.72
  (crate-source "wasm-bindgen-futures" "0.4.72"
                "03qb24gfr072rk8hb69glfdc8yhqqqq2rhy3j5i0ps8sk79dnwwl"))

(define rust-wasm-bindgen-macro-0.2.122
  (crate-source "wasm-bindgen-macro" "0.2.122"
                "1inyl55bvdifx7l60q9wl0ivmw7236jg7jqmcqpxhsx3knq52qci"))

(define rust-wasm-bindgen-macro-support-0.2.122
  (crate-source "wasm-bindgen-macro-support" "0.2.122"
                "0pjw5kc2mbfz59agk5l21kh4hxzp94rygdvsnr4f3z6b5hv4g419"))

(define rust-wasm-bindgen-shared-0.2.122
  (crate-source "wasm-bindgen-shared" "0.2.122"
                "0ds4mmfqvxwc5fp33hn0jblf0f6b4lghrd9mpkls66zic4n9p4ls"))

(define rust-web-atoms-0.2.6
  (crate-source "web_atoms" "0.2.6"
                "1crzqc8s7sckh1rn64gvk0qyabfvizyg9l4dyyxc0gar3df832xs"))

(define rust-web-sys-0.3.99
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.99"
                "0dilfvl9jnyhi4skl6cry9wc300r693j0w82jjbq8yy3rx0i8qkd"))

(define rust-webkit2gtk-2.0.2
  (crate-source "webkit2gtk" "2.0.2"
                "14s7zkrdcqayjz443ia5ba0y86j6i3ghhr40mwpgnc1m058720m1"))

(define rust-webkit2gtk-sys-2.0.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "webkit2gtk-sys" "2.0.2"
                "19affdnf0x698fcjxfzxb59mdm635q59d5gnzw9gw3ggq9jmysli"))

(define rust-webpki-roots-1.0.10
  (crate-source "webpki-roots" "1.0.10"
                "1na80y0p8a3dk62brj7fx1kscjhf52vlxrxzbbbcg3x3r0h8w70w"))

(define rust-webview2-com-0.39.1
  (crate-source "webview2-com" "0.39.1"
                "1rnplwvyqnzpi8sif69g2f1if7clp3dw2m1nrc6y3kh4lykzr29z"))

(define rust-webview2-com-macros-0.8.1
  (crate-source "webview2-com-macros" "0.8.1"
                "0m4vkg7pgcwv3743ka9hgp3ywszrwv6x8g425dxkck4inv0j3ab7"))

(define rust-webview2-com-sys-0.39.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "webview2-com-sys" "0.39.1"
                "1yzdxgnwgqmwsqlp3r4d487ckf2ph4bx3nakb03dc5sifwr7385k"))

(define rust-wezterm-bidi-0.2.3
  (crate-source "wezterm-bidi" "0.2.3"
                "1v7kwmnxfplv9kgdmamn6csbn2ag5xjr0y6gs797slk0alsnw2hc"))

(define rust-wezterm-blob-leases-0.1.1
  (crate-source "wezterm-blob-leases" "0.1.1"
                "1dwf8bm3cwdi37fandwbk7nsfhn9spv4wm0l86gf551xv7vaybb9"))

(define rust-wezterm-color-types-0.3.0
  (crate-source "wezterm-color-types" "0.3.0"
                "15j29f60p1dc0msx50x940niyv9d5zpynavpcc6jf44hbkrixs3x"))

(define rust-wezterm-dynamic-0.2.1
  (crate-source "wezterm-dynamic" "0.2.1"
                "1b6mrk09xxiz66dj3912kmiq8rl7dqig6rwminkfmmhg287bcajz"))

(define rust-wezterm-dynamic-derive-0.1.1
  (crate-source "wezterm-dynamic-derive" "0.1.1"
                "0nspip7gwzmfn66fbnbpa2yik2sb97nckzmgir25nr4wacnwzh26"))

(define rust-wezterm-input-types-0.1.0
  (crate-source "wezterm-input-types" "0.1.0"
                "0zp557014d458a69yqn9dxfy270b6kyfdiynr5p4algrb7aas4kh"))

(define rust-windows-aarch64-gnullvm-0.42.2
  (crate-source "windows_aarch64_gnullvm" "0.42.2"
                "1y4q0qmvl0lvp7syxvfykafvmwal5hrjb4fmv04bqs0bawc52yjr"))

(define rust-windows-aarch64-gnullvm-0.53.1
  (crate-source "windows_aarch64_gnullvm" "0.53.1"
                "0lqvdm510mka9w26vmga7hbkmrw9glzc90l4gya5qbxlm1pl3n59"))

(define rust-windows-aarch64-msvc-0.42.2
  (crate-source "windows_aarch64_msvc" "0.42.2"
                "0hsdikjl5sa1fva5qskpwlxzpc5q9l909fpl1w6yy1hglrj8i3p0"))

(define rust-windows-aarch64-msvc-0.53.1
  (crate-source "windows_aarch64_msvc" "0.53.1"
                "01jh2adlwx043rji888b22whx4bm8alrk3khjpik5xn20kl85mxr"))

(define rust-windows-i686-gnu-0.42.2
  (crate-source "windows_i686_gnu" "0.42.2"
                "0kx866dfrby88lqs9v1vgmrkk1z6af9lhaghh5maj7d4imyr47f6"))

(define rust-windows-i686-gnu-0.53.1
  (crate-source "windows_i686_gnu" "0.53.1"
                "18wkcm82ldyg4figcsidzwbg1pqd49jpm98crfz0j7nqd6h6s3ln"))

(define rust-windows-i686-gnullvm-0.53.1
  (crate-source "windows_i686_gnullvm" "0.53.1"
                "030qaxqc4salz6l4immfb6sykc6gmhyir9wzn2w8mxj8038mjwzs"))

(define rust-windows-i686-msvc-0.42.2
  (crate-source "windows_i686_msvc" "0.42.2"
                "0q0h9m2aq1pygc199pa5jgc952qhcnf0zn688454i7v4xjv41n24"))

(define rust-windows-i686-msvc-0.53.1
  (crate-source "windows_i686_msvc" "0.53.1"
                "1hi6scw3mn2pbdl30ji5i4y8vvspb9b66l98kkz350pig58wfyhy"))

(define rust-windows-sys-0.45.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.45.0"
                "1l36bcqm4g89pknfp8r9rl1w4bn017q6a8qlx8viv0xjxzjkna3m"))

(define rust-windows-sys-0.60.2
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "windows-sys" "0.60.2"
                "1jrbc615ihqnhjhxplr2kw7rasrskv9wj3lr80hgfd42sbj01xgj"))

(define rust-windows-targets-0.42.2
  (crate-source "windows-targets" "0.42.2"
                "0wfhnib2fisxlx8c507dbmh97kgij4r6kcxdi0f9nk6l1k080lcf"))

(define rust-windows-targets-0.53.5
  (crate-source "windows-targets" "0.53.5"
                "1wv9j2gv3l6wj3gkw5j1kr6ymb5q6dfc42yvydjhv3mqa7szjia9"))

(define rust-windows-x86-64-gnu-0.42.2
  (crate-source "windows_x86_64_gnu" "0.42.2"
                "0dnbf2xnp3xrvy8v9mgs3var4zq9v9yh9kv79035rdgyp2w15scd"))

(define rust-windows-x86-64-gnu-0.53.1
  (crate-source "windows_x86_64_gnu" "0.53.1"
                "16d4yiysmfdlsrghndr97y57gh3kljkwhfdbcs05m1jasz6l4f4w"))

(define rust-windows-x86-64-gnullvm-0.42.2
  (crate-source "windows_x86_64_gnullvm" "0.42.2"
                "18wl9r8qbsl475j39zvawlidp1bsbinliwfymr43fibdld31pm16"))

(define rust-windows-x86-64-gnullvm-0.53.1
  (crate-source "windows_x86_64_gnullvm" "0.53.1"
                "1qbspgv4g3q0vygkg8rnql5c6z3caqv38japiynyivh75ng1gyhg"))

(define rust-windows-x86-64-msvc-0.42.2
  (crate-source "windows_x86_64_msvc" "0.42.2"
                "1w5r0q0yzx827d10dpjza2ww0j8iajqhmb54s735hhaj66imvv4s"))

(define rust-windows-x86-64-msvc-0.53.1
  (crate-source "windows_x86_64_msvc" "0.53.1"
                "0l6npq76vlq4ksn4bwsncpr8508mk0gmznm6wnhjg95d19gzzfyn"))

(define rust-winnow-0.5.40
  (crate-source "winnow" "0.5.40"
                "0xk8maai7gyxda673mmw3pj1hdizy5fpi7287vaywykkk19sk4zm"))

(define rust-wry-0.57.1
  (crate-source "wry" "0.57.1"
                "1sghkic2cm8hc66j7c4cnyik615517avjv29nlxr3y8fmpfm173m"))

(define rust-x11-2.21.0
  (crate-source "x11" "2.21.0"
                "0bnvl09d7044k067gqdx1ln2r0ljp5f4675icwb0216d9i3aabah"))

(define rust-yoke-0.8.2
  (crate-source "yoke" "0.8.2"
                "1jprcs7a98a5whvfs6r3jvfh1nnfp6zyijl7y4ywmn88lzywbs5b"))

(define rust-zlib-rs-0.6.7
  (crate-source "zlib-rs" "0.6.7"
                "04mz6314vrfwg8k91qfgs9c71c1icvixcikvki7mls4xilc1vcrl"))


(define rust-arraydeque-0.5.1
  (crate-source "arraydeque" "0.5.1"
                "0dn2xdfg3rkiqsh8a6achnmvf5nf11xk33xgjzpksliab4yjx43x"))

(define rust-arrayvec-0.7.8
  (crate-source "arrayvec" "0.7.8"
                "0mmd8lrijbvg1qp4c5zis5dq41a3mjv2rb6bxkyj9kwaw2k6gyyk"))

(define rust-bitflags-2.13.1
  (crate-source "bitflags" "2.13.1"
                "1nl76mpykmwmb8rq1l5vw1azdh1wvxdrnsk4sy3rdrzx01nvg25m"))

(define rust-bytemuck-derive-1.11.0
  (crate-source "bytemuck_derive" "1.11.0"
                "1r9xdwcdxw385lbflmqlcc2via7hvg7d3zk2ky5mi73bkc2r6mpn"))

(define rust-cc-1.3.0
  (crate-source "cc" "1.3.0"
                "1f27b93qhs65bjq04ljwgwxf8xq2qbba4j1k99cv9d9qav88i5f8"))

(define rust-cfg-expr-0.20.8
  (crate-source "cfg-expr" "0.20.8"
                "0z4r6l4936g1c1s27ryvjdy5pjij6sfvs3myk3hji9dgpi13asgv"))

(define rust-clap-4.6.4
  (crate-source "clap" "4.6.4"
                "1dz5brl39xchkml0khm348i87w89misprlinmnk77vwjawa0q7nr"))

(define rust-clap-builder-4.6.2
  (crate-source "clap_builder" "4.6.2"
                "12sl6fyj6w2djxj0lsc1lkj1h3wpx74fjhb37izvaf65vjpji5ph"))

(define rust-clap-complete-4.6.8
  (crate-source "clap_complete" "4.6.8"
                "12gdj10rdv1di29rhph06j8ifiz7b22mxjzjjp30bgbxa244my5i"))

(define rust-clap-complete-fig-4.5.2
  (crate-source "clap_complete_fig" "4.5.2"
                "0sy88ybw33ba7qj02caxr9jv03wq1f8rdbrbqw81i5gkiwn1156l"))

(define rust-clap-complete-nushell-4.6.1
  (crate-source "clap_complete_nushell" "4.6.1"
                "1qicfrxpcabllnn449hag444j9pjjb3hdlgmxbbmzxizv3ahafwk"))

(define rust-clap-derive-4.6.4
  (crate-source "clap_derive" "4.6.4"
                "0qd0v7pa2arwxjjinmjim6xrjy61bc28m1yryhc7zjjssswx44nh"))

(define rust-clap-mangen-0.3.0
  (crate-source "clap_mangen" "0.3.0"
                "01qghmfrn9d73hkddq085h22h1y3b84n1n0d16za7xprbfs44a6q"))

(define rust-core-maths-0.1.1
  (crate-source "core_maths" "0.1.1"
                "0c0dv11ixxpc9bsx5xasvl98mb1dlprzcm6qq6ls3nsygw0mwx3p"))

(define rust-epoxy-0.1.0
  (crate-source "epoxy" "0.1.0"
                "17jd46cw3dknaq1iz2w3z700zs2q30l470px28irf0zzwf6055lv"))

(define rust-femtovg-0.26.0
  (crate-source "femtovg" "0.26.0"
                "09v8jkcx8cl7903fwwg6jgcs21a9wmp7r0za2kp1dzm449jj3aia"))

(define rust-flume-0.12.0
  (crate-source "flume" "0.12.0"
                "1gnk7gji9r12ig35czj2cq441zf5ijmz0bgnz9gfnxx7dk29n4sy"))

(define rust-fontconfig-0.11.0
  (crate-source "fontconfig" "0.11.0"
                "17avmk88vgnn8iwgfk3j1j61q12cbfy9jwiv0mszdalg2js1w3hd"))

(define rust-fragile-2.1.0
  (crate-source "fragile" "2.1.0"
                "1ygw6asivdkyiy7a427hq17bvspr31pzsas1ia0nxf2bl55qcy48"))

(define rust-futures-0.3.33
  (crate-source "futures" "0.3.33"
                "066j5aqz8an05xh4hn5ljdnjn80z3g335v4grx4gaifr57wg3358"))

(define rust-futures-channel-0.3.33
  (crate-source "futures-channel" "0.3.33"
                "1bn5hlhfkl1sgypmiachaqcgwmr6wmjal7dyhfyb1zkazvs90996"))

(define rust-futures-core-0.3.33
  (crate-source "futures-core" "0.3.33"
                "1iqdbvcdlplfr2g43h7xrfkv2sg5p1a26x8acz1xgxl07i3hrm9c"))

(define rust-futures-executor-0.3.33
  (crate-source "futures-executor" "0.3.33"
                "0n3lpkmcfrsnh40i4armn040gnqbpd257hz5qs46zipjr6f8fm37"))

(define rust-futures-io-0.3.33
  (crate-source "futures-io" "0.3.33"
                "0yjx13qdm9b2p4w00ddw85k6yccnnmqrlrrz8yfmi5jg7jmfqxs5"))

(define rust-futures-macro-0.3.33
  (crate-source "futures-macro" "0.3.33"
                "02xiyd5y1nk9b805aympj4wq2czgvxnhcml9w9xkc665d3g3qv9d"))

(define rust-futures-sink-0.3.33
  (crate-source "futures-sink" "0.3.33"
                "01z38z344hpryw84b6r0rbwcb669d8pyvl2szg10aqwx96n1hi73"))

(define rust-futures-task-0.3.33
  (crate-source "futures-task" "0.3.33"
                "02f1y1yvjg1cv998zkgl1706pi9y4fyc9045l1hlmyqyhclfscdj"))

(define rust-futures-util-0.3.33
  (crate-source "futures-util" "0.3.33"
                "1anyg40j5www5l22r2jbn1birsafz4q1w9qmcjk4vqzwasi90ym7"))

(define rust-gl-generator-0.9.0
  (crate-source "gl_generator" "0.9.0"
                "02lx6zfvpszp43161645hvj06smfbi9dgmjqm9xmlnyqrdq52ybs"))

(define rust-glow-0.18.0
  (crate-source "glow" "0.18.0"
                "11hk5m3sir58y17wj8dmjhak7apqyms4dc0g6z1ia1rbpaq1hci6"))

(define rust-gvdb-0.10.0
  (crate-source "gvdb" "0.10.0"
                "11nllqpvlnlvfrqw2sn9ddng4jhw2y1xh7nj91lrw3aj67pdqfmw"))

(define rust-hex-color-3.0.0
  (crate-source "hex_color" "3.0.0"
                "1w2f91y34b30x8jy6y4f37fh6i9ia1h16pjb5v5gfcy6yhdi0zyk"))

(define rust-image-0.25.10
  (crate-source "image" "0.25.10"
                "0131b9fsd5grxf3lchfs2ci0rg8ga2mh1ygai7k2zh1k8cwq1aw5"))

(define rust-imgref-1.12.2
  (crate-source "imgref" "1.12.2"
                "1msc8g8x8a9dy3l85ila4sijvnhr1rxrxsbjhqk1bawkm64lc6c9"))

(define rust-itertools-0.15.0
  (crate-source "itertools" "0.15.0"
                "1p412hriqm4kxn7x1539vz2p5c5s1v2m36m4kis2ai4dyn9syjwb"))

(define rust-js-sys-0.3.103
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.103"
                "00lib0b6hqmw56r2hjp7xrv730qacslirbkdlhvmi39zvgy4pd2k"))

(define rust-keycode-1.0.0
  (crate-source "keycode" "1.0.0"
                "0xb9fawn3crmwg09i2jjbb4hg9f1h81rif51d0fflh1rscqihm19"))

(define rust-keycode-macro-1.0.0
  (crate-source "keycode_macro" "1.0.0"
                "1cnaxds4mkhcrpc410ygb47lgbwcxs768riv4qf54k85i33wrb2g"))

(define rust-khronos-api-2.2.0
  (crate-source "khronos_api" "2.2.0"
                "0m5mpi5zyzzbsjkfymfkzib577ii8lk3l5p9sgxvarrzqdrb8yh3"))

(define rust-libloading-0.9.0
  (crate-source "libloading" "0.9.0"
                "0q4bvhp4kqy2v3bw4cn2bmyq73hskqd1ansa9125gfq5x0ns4k3m"))

(define rust-lru-0.18.1
  (crate-source "lru" "0.18.1"
                "19m5i0kwfny3iwmwjis4mlp53spnj4059amh01q91vi714a80q8b"))

(define rust-moxcms-0.8.1
  (crate-source "moxcms" "0.8.1"
                "0jz4fd5f7pdn1rngqc96lxriqjkym1lswdhdbjr037s8p9ac31dv"))

(define rust-quick-xml-0.39.4
  (crate-source "quick-xml" "0.39.4"
                "0plfhnna58ad2hlym3q02zrmmh7xdpikzs7hll4x6w7nwba8vk6d"))

(define rust-rand-0.8.7
  (crate-source "rand" "0.8.7"
                "06iaf16fr0z8zly7anmn8ky0p80xnx9yv0gdcm30fwn9vqmigxi2"))

(define rust-relm4-0.10.1
  (crate-source "relm4" "0.10.1"
                "0wm411qc48rbc8jkc8pfxqibb86822p543wj7r70d16912fnf08p"))

(define rust-relm4-css-0.10.1
  (crate-source "relm4-css" "0.10.1"
                "05ibbj60rzhl9v2909jf7bl7ygzab565pnpabyvqsqa13ng2ipxi"))

(define rust-relm4-icons-0.10.1
  (crate-source "relm4-icons" "0.10.1"
                "1pkrgvihazn8qmqp7zh0w273zzh66qn7w8ghpmgw7kk05p25bn4q"))

(define rust-relm4-icons-build-0.11.0
  (crate-source "relm4-icons-build" "0.11.0"
                "1lipfksr00vi4sj4smc5vzprv69pckiypkdpfbvlfvvd0v2l46qb"))

(define rust-relm4-macros-0.10.1
  (crate-source "relm4-macros" "0.10.1"
                "07lp8cr7n912vybxrl7f1cazq2iirm45rs6q3mgrf9l15rdvpv95"))

(define rust-resource-0.6.1
  (crate-source "resource" "0.6.1"
                "0xl1sq95x7l7j3fg3drbxm4mkff3lcm1yjynpgbr70gr7hi54ygp"))

(define rust-resource-list-proc-macro-0.6.1
  (crate-source "resource_list_proc_macro" "0.6.1"
                "05p828pfcgcc9gp0x4ycxj0m2lh2rjis6bwfbpj4izbxywx7vrys"))

(define rust-rgb-0.8.53
  (crate-source "rgb" "0.8.53"
                "1i0c55whln68zs6f5qqrkbg1mzai0p3qk1mwkwzdgr9i3dw4pcs7"))

(define rust-roff-1.1.1
  (crate-source "roff" "1.1.1"
                "12c1pibjxdjai80hpalxgqkzn30316x49iry4rdscrcn3mz42g1j"))

(define rust-rustybuzz-0.20.1
  (crate-source "rustybuzz" "0.20.1"
                "00hp1gwykjfli258zs7lqg8p2zdh94dv2mw8zx7f73m0z2b7qg7x"))

(define rust-spin-0.9.9
  (crate-source "spin" "0.9.9"
                "03psal0vh1xdxp7agphw09p7kf50v3bj1zshijq1s5bkdd7jcqrp"))

(define rust-syn-3.0.2
  (crate-source "syn" "3.0.2"
                "18w7g5b9c585jw2rgvhygqdli8hq7w2jcds4h05lgz5plbbdc1x2"))

(define rust-target-lexicon-0.13.5
  (crate-source "target-lexicon" "0.13.5"
                "1jm6lmf9hsn7ri2d6v9gg6fy24lylhskh6pbxh71f82wdxd97dmd"))

(define rust-thiserror-2.0.19
  (crate-source "thiserror" "2.0.19"
                "1ngwxsjsa64v1n7vb90h2b0i3fqk1piwaf0z6fqdacqfhjc3b909"))

(define rust-thiserror-impl-2.0.19
  (crate-source "thiserror-impl" "2.0.19"
                "1ka10pqy1g8zy5al9m8yadg30jp8hx0q80j8awmd8131yw6gxjs3"))

(define rust-tokio-1.53.1
  (crate-source "tokio" "1.53.1"
                "1v8b3b45pkpbibls75yniqbvx5dlks2708141ljni5mnf6lawb10"))

(define rust-toml-1.1.3+spec-1.1.0
  (crate-source "toml" "1.1.3+spec-1.1.0"
                "0g2c3lqf61ss14ak0lzg5r8fvsx8mnclzldfzk28y74lzb6nxjak"))

(define rust-toml-edit-0.25.13+spec-1.1.0
  (crate-source "toml_edit" "0.25.13+spec-1.1.0"
                "16xgmjdnxssdpj7rjyimsk4fqbv29g8zl7zhdbc6dxrf9mz3cxb9"))

(define rust-ttf-parser-0.25.1
  (crate-source "ttf-parser" "0.25.1"
                "0cbgqglcwwjg3hirwq6xlza54w04mb5x02kf7zx4hrw50xmr1pyj"))

(define rust-unicode-bidi-0.3.18
  (crate-source "unicode-bidi" "0.3.18"
                "1xcxwbsqa24b8vfchhzyyzgj0l6bn51ib5v8j6krha0m77dva72w"))

(define rust-unicode-bidi-mirroring-0.4.0
  (crate-source "unicode-bidi-mirroring" "0.4.0"
                "1zirs1z3ahlwy7swg7apnm3pc6vix1g15q0kn6fx8rmvc266xyjx"))

(define rust-unicode-ccc-0.4.0
  (crate-source "unicode-ccc" "0.4.0"
                "0gjhxwx27ywm3rcbb0m5q20w8zxi51440b3ps6swi6ywpj4d8qff"))

(define rust-unicode-properties-0.1.4
  (crate-source "unicode-properties" "0.1.4"
                "07fpm3sqq7lm9gmgpxa93z31q933h3c3ypfwy4cdh6l42g3miw3x"))

(define rust-unicode-script-0.5.8
  (crate-source "unicode-script" "0.5.8"
                "1vmifpgd0map3frmvhszhl96k82crcry083prv05wii7p45x8fiq"))

(define rust-wasm-bindgen-0.2.126
  (crate-source "wasm-bindgen" "0.2.126"
                "197rma4qg1kb8l4bl7857pgszzval8s1w740g9myyjh92467q1jb"))

(define rust-wasm-bindgen-macro-0.2.126
  (crate-source "wasm-bindgen-macro" "0.2.126"
                "1cda6wl5zyiy7777cfgrix7fhpaqba55l5zpqj4zig7ng7jyaz0n"))

(define rust-wasm-bindgen-macro-support-0.2.126
  (crate-source "wasm-bindgen-macro-support" "0.2.126"
                "03iq412frl2py55skwb3ya08xha0cf6q22zr5kqlwbr675w7r6gk"))

(define rust-wasm-bindgen-shared-0.2.126
  (crate-source "wasm-bindgen-shared" "0.2.126"
                "097a3kbjls447s1lwr41l21x5crrh5vq3h6zsxccz7slrjq4q6yw"))

(define rust-web-sys-0.3.103
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.103"
                "0hb1zdnrp99p5r5q66jagsddmwha460yv2wklvzrzk0b3jvdq8l6"))

(define rust-xml-rs-0.7.0
  (crate-source "xml-rs" "0.7.0"
                "1hp9kf80y9qm3aiqg5psyshqfkcrjgifbcm2c2nc5qlzs80vc71w"))

(define rust-yeslogic-fontconfig-sys-6.0.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "yeslogic-fontconfig-sys" "6.0.1"
                "0xjgmw2nh3hr6wh72s9ss41njqrkgk4p25if27zjk6ibj6zqm2qx"))

(define rust-zerocopy-0.8.54
  (crate-source "zerocopy" "0.8.54"
                "06cxymy8i9q9a93xdins9ayakx9b1nc2arb7qdfd03ssf05brjxp"))

(define rust-zerocopy-derive-0.8.54
  (crate-source "zerocopy-derive" "0.8.54"
                "1xb292dhgb0d4fs05cdj2s0v3srmk7bajv94sdc7631dnnvigs72"))

(define rust-zvariant-5.13.1
  (crate-source "zvariant" "5.13.1"
                "04a9r40d5vd4q6gaww8bynjrnk7mmam4bzvg8mm7h1x9saya1qmy"))

(define rust-zvariant-derive-5.13.1
  (crate-source "zvariant_derive" "5.13.1"
                "04iywbj0dg5v6iapb6vqiwz3mj67753kzzhbfyb0fy0qd8hhi9rq"))

(define rust-zvariant-utils-3.5.0
  (crate-source "zvariant_utils" "3.5.0"
                "1iy79yppaqsw0pjb8q7b36vivw7qsc1b4n0jg9090lmlz61r7jwh"))


(define rust-ab-glyph-0.2.32
  (crate-source "ab_glyph" "0.2.32"
                "1hkc7y8yjd261d5cm9771dawnwc26rgdlniv3jysb3n3f9s4bh01"))

(define rust-ab-glyph-rasterizer-0.1.10
  (crate-source "ab_glyph_rasterizer" "0.1.10"
                "065n6bj7kqk6f12336lm87fqmvf4lxg7rkg2j56nix228jmgnvrn"))

(define rust-alacritty-terminal-0.26.0
  (crate-source "alacritty_terminal" "0.26.0"
                "0nfgdzchwjhw09cyk9wjk677i5l6nqqdvw0j3fgxa94mdd37g8dx"))

(define rust-arboard-3.6.1
  (crate-source "arboard" "3.6.1"
                "1byx6q5iipxkb0pyjp80k7c4akp4n5m7nsmqdbz4n7s9ak0a2j03"))

(define rust-arrayref-0.3.9
  (crate-source "arrayref" "0.3.9"
                "1jzyp0nvp10dmahaq9a2rnxqdd5wxgbvp8xaibps3zai8c9fi8kn"))

(define rust-ascii-1.1.0
  (crate-source "ascii" "1.1.0"
                "05nyyp39x4wzc1959kv7ckwqpkdzjd9dw4slzyjh73qbhjcfqayr"))

(define rust-ash-0.38.0+1.3.281
  (crate-source "ash" "0.38.0+1.3.281"
                "0vx4yf689v1rc680jvy8bnysx5sgd8f33wnp2vqaizh0v0v4kd0b"))

(define rust-bitvec-1.0.1
  (crate-source "bitvec" "1.0.1"
                "173ydyj2q5vwj88k6xgjnfsshs4x9wbvjjv7sm0h36r34hn87hhv"))

(define rust-block-0.1.6
  (crate-source "block" "0.1.6"
                "16k9jgll25pzsq14f244q22cdv0zb4bqacldg3kx6h89d7piz30d"))

(define rust-block-buffer-0.12.0
  (crate-source "block-buffer" "0.12.0"
                "1glh8w49a7cj0wlkalyn9j605jzf2ss0lg8dqq5xh8cr2q451lyd"))

(define rust-cc-1.2.61
  (crate-source "cc" "1.2.61"
                "0vawvnrrsmi8dygavq3wx085cmlp10sp3fhld5842rlqkqsr0vfi"))

(define rust-chardetng-0.1.17
  (crate-source "chardetng" "0.1.17"
                "1spikjcnblwa5n1nnk46fxkwn86yfiqxgs47h4yaw23vbfvg1f0l"))

(define rust-chunked-transfer-1.5.0
  (crate-source "chunked_transfer" "1.5.0"
                "00a9h3csr1xwkqrzpz5kag4h92zdkrnxq4ppxidrhrx29syf6kbf"))

(define rust-clipboard-win-5.4.3
  (crate-source "clipboard-win" "5.4.3"
                "16isdlcwrj0jgjs5k5c0jvr15mqrs1knlyms2bdcrzk6hj3zfah5"))

(define rust-cobs-0.3.0
  (crate-source "cobs" "0.3.0"
                "18f0kxxa1fqb8pz2dxwssnhsrvhrs5j4p8xllgin5d7h36sn3a8g"))

(define rust-codespan-reporting-0.12.0
  (crate-source "codespan-reporting" "0.12.0"
                "108g41xqzhr8fx8hlpy5qzmqq8ylldbj37wndkaqm34yy1d2wvgy"))

(define rust-compact-str-0.9.0
  (crate-source "compact_str" "0.9.0"
                "0ykhh2scg32lmzxak107pmby6fmnz7qbhsi9i8g9iknfl4ji7nrz"))

(define rust-const-oid-0.10.2
  (crate-source "const-oid" "0.10.2"
                "0p7m286mp8aai4sa72g7ji6qm0d4ns8wg4i4b2hj9p9615zm3vx6"))

(define rust-const-random-0.1.18
  (crate-source "const-random" "0.1.18"
                "0n8kqz3y82ks8znvz1mxn3a9hadca3amzf33gmi6dc3lzs103q47"))

(define rust-const-random-macro-0.1.16
  (crate-source "const-random-macro" "0.1.16"
                "03iram4ijjjq9j5a7hbnmdngj8935wbsd0f5bm8yw2hblbr3kn7r"))

(define rust-cow-utils-0.1.3
  (crate-source "cow-utils" "0.1.3"
                "0y9cxf0hm2hy4bn050wl2785md5q4i5gy9asjq006ip1mwjfyys1"))

(define rust-crossbeam-epoch-0.9.21
  (crate-source "crossbeam-epoch" "0.9.21"
                "17bdp2linl0milbmx00s3bda3fphgc85im1gqwa3p6hhhw39hx6w"))

(define rust-crypto-common-0.2.1
  (crate-source "crypto-common" "0.2.1"
                "041p8bs680hrg6rhicfifn19cfvybq9aya5i4i0k08d9byqpnwkp"))

(define rust-ctor-0.6.3
  (crate-source "ctor" "0.6.3"
                "03jrw316acxl3vld3wvl5m8jkj0mwwbssx7i06sb5blg4ww02kj2"))

(define rust-ctor-proc-macro-0.0.7
  (crate-source "ctor-proc-macro" "0.0.7"
                "1havwah6iryn0ang09y12xxr45jsp7ff27zflz4mhgk017ghlmjj"))

(define rust-darling-0.23.0
  (crate-source "darling" "0.23.0"
                "179fj6p6ajw4dnkrik51wjhifxwy02x5zhligyymcb905zd17bi5"))

(define rust-darling-core-0.23.0
  (crate-source "darling_core" "0.23.0"
                "1c033vrks38vpw8kwgd5w088dsr511kfz55n9db56prkgh7sarcq"))

(define rust-darling-macro-0.23.0
  (crate-source "darling_macro" "0.23.0"
                "13fvzji9xyp304mgq720z5l0xgm54qj68jibwscagkynggn88fdc"))

(define rust-dirs-6.0.0
  (crate-source "dirs" "6.0.0"
                "0knfikii29761g22pwfrb8d0nqpbgw77sni9h2224haisyaams63"))

(define rust-doctest-file-1.1.1
  (crate-source "doctest-file" "1.1.1"
                "0nfkscv8gf3ixhradrmwm3f2p6sc0ab0psah7c8976ha9zkh9ny2"))

(define rust-dragonbox-ecma-0.1.12
  (crate-source "dragonbox_ecma" "0.1.12"
                "1gs6yz1klalmhmvq8wrmxz0cnc41c4xlb7iz5pv7wzn3hh8713px"))

(define rust-dtor-0.1.1
  (crate-source "dtor" "0.1.1"
                "00fkcw8zn0g10m4k8b0qgmn304g47xqwn1ihhzyjra48n3p04ka0"))

(define rust-dtor-proc-macro-0.0.6
  (crate-source "dtor-proc-macro" "0.0.6"
                "19fg0mivy9qyvbwmqj3ysj0qm5cay0gyp5fyw1imq89cj95cyy7n"))

(define rust-embedded-io-0.4.0
  (crate-source "embedded-io" "0.4.0"
                "1v9wrc5nsgaaady7i3ya394sik5251j0iq5rls7mrx7fv696h6pg"))

(define rust-evictor-0.5.1
  (crate-source "evictor" "0.5.1"
                "077axkrwg396r53izw2axxxa9f6ssg11p6clx5amj71x8j0lr6zv"))

(define rust-fancy-regex-0.16.2
  (crate-source "fancy-regex" "0.16.2"
                "0vy4c012f82xcg3gs068mq110zhsrnajh58fmq1jxr7vaijhb2wr"))

(define rust-fixedbitset-0.5.7
  (crate-source "fixedbitset" "0.5.7"
                "16fd3v9d2cms2vddf9xhlm56sz4j0zgrk3d2h6v1l7hx760lwrqx"))

(define rust-fluent-uri-0.1.4
  (crate-source "fluent-uri" "0.1.4"
                "03ah2qajw5l1zbc81kh1n8g7n24mfxbg6vqyv9ixipg1vglh9iqp"))

(define rust-funty-2.0.0
  (crate-source "funty" "2.0.0"
                "177w048bm0046qlzvp33ag3ghqkqw4ncpzcm5lq36gxf2lla7mg6"))

(define rust-glow-0.16.0
  (crate-source "glow" "0.16.0"
                "022z12nlyfpy36fvp2szq792xix1xbgkznpmicf1c404sxhfmrf5"))

(define rust-glutin-wgl-sys-0.6.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "glutin_wgl_sys" "0.6.1"
                "0gng2810jb5x133lmy17qifjx6s90lnprm86afg7mfls505y0kic"))

(define rust-gpu-allocator-0.28.0
  (crate-source "gpu-allocator" "0.28.0"
                "15c7izilxm5j52d9hr9kqjb2pjram293xm182mgnrnxarykmw9ai"))

(define rust-gpu-descriptor-0.3.2
  (crate-source "gpu-descriptor" "0.3.2"
                "1jm0acxkw9lrzzcbvjqynwdr53qsqz7vx5d8c8h77qq5j4s8775q"))

(define rust-gpu-descriptor-types-0.2.0
  (crate-source "gpu-descriptor-types" "0.2.0"
                "14ab90klss7w0ybj95fcnqxjsjya17xjhf576dpvi4zq5ml45wpx"))

(define rust-hexf-parse-0.2.1
  (crate-source "hexf-parse" "0.2.1"
                "1pr3a3sk66ddxdyxdxac7q6qaqjcn28v0njy22ghdpfn78l8d9nz"))

(define rust-hybrid-array-0.4.11
  (crate-source "hybrid-array" "0.4.11"
                "1i878m874s249357fx3rzj4fx8b4rlrxw19vpnazwlgdl0vnim08"))

(define rust-ignore-0.4.25
  (crate-source "ignore" "0.4.25"
                "0jlv2s4fxqj9fsz6y015j5vbz6i475hj80j9q3sy05d0cniq5myk"))

(define rust-include-dir-0.7.4
  (crate-source "include_dir" "0.7.4"
                "1pfh3g45z88kwq93skng0n6g3r7zkhq9ldqs9y8rvr7i11s12gcj"))

(define rust-include-dir-macros-0.7.4
  (crate-source "include_dir_macros" "0.7.4"
                "0x8smnf6knd86g69p19z5lpfsaqp8w0nx14kdpkz1m8bxnkqbavw"))

(define rust-inotify-0.11.1
  (crate-source "inotify" "0.11.1"
                "16fiffnqhfdwzgrv3wcnaih0a9xbx1a44nma1yn5idr83apkwnxx"))

(define rust-inotify-sys-0.1.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "inotify-sys" "0.1.5"
                "1syhjgvkram88my04kv03s0zwa66mdwa5v7ddja3pzwvx2sh4p70"))

(define rust-instability-0.3.12
  (crate-source "instability" "0.3.12"
                "0wc98mr44w5k1y6pib2x0kydmhbff8gkfgiw36ls684ry47ddcjy"))

(define rust-interprocess-2.4.2
  (crate-source "interprocess" "2.4.2"
                "0nsr54v0i2ac0cfnccf5ks8vcdhxj7nw3rcgdaq7mjq06is274q6"))

(define rust-js-sys-0.3.97
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.97"
                "1kyaxgn1sm5am98jb48aj5j7r7s98kdrab41la5wzys5q2a0r151"))

(define rust-jsonc-parser-0.34.0
  (crate-source "jsonc-parser" "0.34.0"
                "0j1zyw2h6kqkp7xv7bzns5ikc99jgijl52k6766p36lv9w4fvk8f"))

(define rust-keyboard-types-0.7.0
  (crate-source "keyboard-types" "0.7.0"
                "12jjfk7dwa1cqp6wzw0xl1zzg3arsrnqy4afsynxn2csqfnxql5p"))

(define rust-khronos-egl-6.0.0
  (crate-source "khronos-egl" "6.0.0"
                "0xnzdx0n1bil06xmh8i1x6dbxvk7kd2m70bbm6nw1qzc43r1vbka"))

(define rust-kqueue-1.1.1
  (crate-source "kqueue" "1.1.1"
                "0sjrsnza8zxr1zfpv6sa0zapd54kx9wlijrz9apqvs6wsw303hza"))

(define rust-kqueue-sys-1.1.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "kqueue-sys" "1.1.0"
                "0byssypr815kj1kxbk8sxc70yjmx5ngncbl8z8irz52z85h5idm7"))

(define rust-libxdo-0.6.0
  (crate-source "libxdo" "0.6.0"
                "1nqlina6li1bmap0144h4hdsczyyfyinf87qvrw8xlm3as3kncq0"))

(define rust-libxdo-sys-0.11.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libxdo-sys" "0.11.0"
                "04ljl0lmirg8a9q7w8ib2sybx35nnzpbw2xciayip0xpwbkvj8yv"))

(define rust-linked-hash-map-0.5.6
  (crate-source "linked-hash-map" "0.5.6"
                "03vpgw7x507g524nx5i1jf5dl8k3kv0fzg8v3ip6qqwbpkqww5q7"))

(define rust-lru-0.16.4
  (crate-source "lru" "0.16.4"
                "0fgg35wrpfdrkv9hcabkg92g3sv4867g1rir7ay9lq1zs3ayhrkz"))

(define rust-lsp-types-0.97.0
  (crate-source "lsp-types" "0.97.0"
                "0wb0yr2cdhlndjkcfyabr17ib0nvqa4v3zl5qm3aq13wl583adak"))

(define rust-lyon-geom-1.0.19
  (crate-source "lyon_geom" "1.0.19"
                "14ib0jwn7rhxggvrsjdxnp71fg00sr723lnsy8ygjap354p50dj3"))

(define rust-lzma-sys-0.1.20
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "lzma-sys" "0.1.20"
                "09sxp20waxyglgn3cjz8qjkspb3ryz2fwx4rigkwvrk46ymh9njz"))

(define rust-malloc-buf-0.0.6
  (crate-source "malloc_buf" "0.0.6"
                "1jqr77j89pwszv51fmnknzvd53i1nkmcr8rjrvcxhm4dx1zr1fv2"))

(define rust-metal-0.33.0
  (crate-source "metal" "0.33.0"
                "05dwbjpdrhbnfq2jgdx0m5j9ip3ibwsln0b3v663p45wnn8pf167"))

(define rust-miow-0.6.1
  (crate-source "miow" "0.6.1"
                "023g6jamln6hmspcllgrm99ri38ypbm8w945jh36579hgb9zlssk"))

(define rust-muda-0.17.2
  (crate-source "muda" "0.17.2"
                "0xv1x0rgzr9pi63074rg1f7qz0q5lrihblbqsy1h71l99rdfr7vw"))

(define rust-naga-28.0.0
  (crate-source "naga" "28.0.0"
                "0d8idx407r0lnqbcjl097wyfr6lavf3i09b1zkfijch64mr6d3v1"))

(define rust-nonmax-0.5.5
  (crate-source "nonmax" "0.5.5"
                "0lfvyfz4falgmc9g1cbfi2wkys9wka2nfmdyga87zikf636ml2k1"))

(define rust-notify-8.2.0
  (crate-source "notify" "8.2.0"
                "1hrb83451vm5cpjw83nz5skgwjg5ara28zq8nxsqbzsif690fgad"))

(define rust-notify-types-2.1.0
  (crate-source "notify-types" "2.1.0"
                "0yj710mxd4lsaz4hq7601mh6xb02awb8hg4z6lvh76ik1vpczf22"))

(define rust-num-conv-0.2.1
  (crate-source "num-conv" "0.2.1"
                "0rqrr29brafaa2za352pbmhkk556n7f8z9rrkgmjp1idvdl3fry6"))

(define rust-objc-0.2.7
  (crate-source "objc" "0.2.7"
                "1cbpf6kz8a244nn1qzl3xyhmp05gsg4n313c9m3567625d3innwi"))

(define rust-onig-6.5.3
  (crate-source "onig" "6.5.3"
                "1qh9qyv59ca5py5x5bvmfpi9sjyhls80r20sq638jhzrk3vcphqc"))

(define rust-onig-sys-69.9.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "onig_sys" "69.9.3"
                "1mzd6l3vjb8iw7jwk7l99jvj279wh0d8wf4nb2w56zp70iv32s0y"))

(define rust-open-5.3.4
  (crate-source "open" "5.3.4"
                "1z9pbnc0lx1lqx1p74szfar7rv21shcggkjzyymmga19giqsnfwz"))

(define rust-orbclient-0.3.54
  (crate-source "orbclient" "0.3.54"
                "0agkiynbz28x1020il9v66dbr6gcfg4afacj2fraqa8xljygcw55"))

(define rust-os-pipe-1.2.3
  (crate-source "os_pipe" "1.2.3"
                "0rqrvm7fdp790b4ks3kcdzsgkz2528xrn3vxc9l4nf1inj2ax3vx"))

(define rust-owned-ttf-parser-0.25.1
  (crate-source "owned_ttf_parser" "0.25.1"
                "0fsqzcbc4sq8qhkmc3rgcfg1xg389nmhlxvmvi6h38dca680x0in"))

(define rust-owo-colors-4.3.0
  (crate-source "owo-colors" "4.3.0"
                "0kgrf4r9vcczhw5r30nkcl6abm99l0ay8dr2fxl0ymvbkcxq04fj"))

(define rust-oxc-allocator-0.128.0
  (crate-source "oxc_allocator" "0.128.0"
                "1jsjv77sxf4rc6pnw974kmyy8kk94iakbwrbi95nirfxig24qmcb"))

(define rust-oxc-ast-0.128.0
  (crate-source "oxc_ast" "0.128.0"
                "0c1dv820l7da1rbb8mrkg9bapcxckl6bif0d3rqy2mrjnbwdh9yh"))

(define rust-oxc-ast-macros-0.128.0
  (crate-source "oxc_ast_macros" "0.128.0"
                "17nhg1fxhz895l3v02lx6g673131hmdmih9x3s0n76dw0p5wj2il"))

(define rust-oxc-ast-visit-0.128.0
  (crate-source "oxc_ast_visit" "0.128.0"
                "1nzqslcj1h5w2v49y7q8bsmysp20j556yq84s2njl5d8ylgg35ng"))

(define rust-oxc-browserslist-3.0.2
  (crate-source "oxc-browserslist" "3.0.2"
                "13makwg8683p6s36lgm2jwn5yv2dn9gkfaybbvzn00hhx5sz1q9v"))

(define rust-oxc-codegen-0.128.0
  (crate-source "oxc_codegen" "0.128.0"
                "0psqxmzgp4rcg12kf6g9q1wqkl4dmwsdldk086yz7g7a16nhzxaf"))

(define rust-oxc-compat-0.128.0
  (crate-source "oxc_compat" "0.128.0"
                "1rmbsxnawnf9ww7d0ngk07zzdhw99j5xlww0655khzs4h3d69fd3"))

(define rust-oxc-data-structures-0.128.0
  (crate-source "oxc_data_structures" "0.128.0"
                "0g221dv0m7ls208sbzq6vqc0qjind4nqk1ips6vdj0snl30ws9f4"))

(define rust-oxc-diagnostics-0.128.0
  (crate-source "oxc_diagnostics" "0.128.0"
                "1vnri98clglgbcxw3yyhy0dw0a9vvn05z4qbngk7c75kqfzc01ps"))

(define rust-oxc-ecmascript-0.128.0
  (crate-source "oxc_ecmascript" "0.128.0"
                "17dym0af4313bp9ljalzympkwccg480kxsxpnqb7141f2anxfxf6"))

(define rust-oxc-estree-0.128.0
  (crate-source "oxc_estree" "0.128.0"
                "1x3lmd7y6crgwalw7i33wmdy3krfb02bmkhm2a3mnwxjhi825vqa"))

(define rust-oxc-index-4.1.0
  (crate-source "oxc_index" "4.1.0"
                "0avc8488591cj2l34xjmjmzbn3j1kxyanph20fbyq9wnk4h62gpb"))

(define rust-oxc-isolated-declarations-0.128.0
  (crate-source "oxc_isolated_declarations" "0.128.0"
                "1ki0kkrfxbhzp290x5mvwidk783nk07h75q1piijm8f8s3mk05pk"))

(define rust-oxc-miette-2.7.1
  (crate-source "oxc-miette" "2.7.1"
                "0p14fhxakvyhp5yzh6b929vv43lp92zmy8a509hv7jfl5qgscmj3"))

(define rust-oxc-miette-derive-2.7.1
  (crate-source "oxc-miette-derive" "2.7.1"
                "15pn3cy0g7xkxf5wh8hsambqsgyijzk7k4xvfpzqz3sg04ml4dxj"))

(define rust-oxc-parser-0.128.0
  (crate-source "oxc_parser" "0.128.0"
                "0pxczb73a9y73cqz5lylanh44axsqfjajm53xmz9aszgw1q75lka"))

(define rust-oxc-regular-expression-0.128.0
  (crate-source "oxc_regular_expression" "0.128.0"
                "0ay2sgshadsi2i2n9r27z99wa660b4qnpxi8amki0nb4z3fxv4ly"))

(define rust-oxc-semantic-0.128.0
  (crate-source "oxc_semantic" "0.128.0"
                "1blhkgfp91f8mrjhdswwp7kybxjf3i36293cb0imc9sha43xk2j9"))

(define rust-oxc-span-0.128.0
  (crate-source "oxc_span" "0.128.0"
                "0ng6arai9jpqh4gwsg1g1lq2n64pl172xy23pbdzym129jp58fzh"))

(define rust-oxc-str-0.128.0
  (crate-source "oxc_str" "0.128.0"
                "0nks287pspncvy8ham14ycf2gb2363ignw8qjac3cjjsivjhyv38"))

(define rust-oxc-syntax-0.128.0
  (crate-source "oxc_syntax" "0.128.0"
                "1svkdazhlhk6z2pqls0i6cpnr97fbd64sj6jir8lqbfra0zf3h1m"))

(define rust-oxc-transformer-0.128.0
  (crate-source "oxc_transformer" "0.128.0"
                "17pl3y2ly5vy9c2kjwwx1vszhvb5hywnrilm7v7vabppl5hqn8z7"))

(define rust-oxc-traverse-0.128.0
  (crate-source "oxc_traverse" "0.128.0"
                "1zskm1i7nrpwli1gkmrf3bc78nagckdpcl8swr6hrwmnm6iy2q2g"))

(define rust-petgraph-0.8.3
  (crate-source "petgraph" "0.8.3"
                "0mblnaqbx1y20h5y7pz6y11hk9jjk6k87lsmn7jxaq3hm67ba0c7"))

(define rust-pin-project-1.1.12
  (crate-source "pin-project" "1.1.12"
                "1sbcs3s240z2w4jaga53c3jl5maw4qprf0a9kfcagcq0h7kdkw6b"))

(define rust-pin-project-internal-1.1.12
  (crate-source "pin-project-internal" "1.1.12"
                "12a3c85sa005ahk1qm673h1akx2fa8qfvpb0ybd5aj788cpy5459"))

(define rust-png-0.17.16
  (crate-source "png" "0.17.16"
                "09kmkms9fmkbkarw0lnf0scqvjwwg3r7riddag0i3q39r0pil5c2"))

(define rust-postcard-1.1.3
  (crate-source "postcard" "1.1.3"
                "094srff139n7m8g5ssq36ag6s29ikf7fgpz660x2hkj5vnsw6r37"))

(define rust-presser-0.3.1
  (crate-source "presser" "0.3.1"
                "1ykvqx861sjmhkdh540aafqba7i7li7gqgwrcczy6v56i9m8xkz8"))

(define rust-proc-macro-crate-2.0.0
  (crate-source "proc-macro-crate" "2.0.0"
                "1s23imns07vmacn2xjd5hv2h6rr94iqq3fd2frwa6i4h2nk6d0vy"))

(define rust-profiling-1.0.18
  (crate-source "profiling" "1.0.18"
                "1xdwlvxlgy99nn1dra7arzinkc8lbqljvcwpq70m7g16lda5wn9x"))

(define rust-pulldown-cmark-0.13.6
  (crate-source "pulldown-cmark" "0.13.6"
                "0yxvd4k7xpdvjhmzxdpbaixphdy509s5yzzsyk9ks0azhd3bxcix"))

(define rust-radium-0.7.0
  (crate-source "radium" "0.7.0"
                "02cxfi3ky3c4yhyqx9axqwhyaca804ws46nn4gc1imbk94nzycyw"))

(define rust-range-alloc-0.1.5
  (crate-source "range-alloc" "0.1.5"
                "020xrpn0qaabkxg49wpi0hgy92d8ikji55cyancphnmfi6bl2ifa"))

(define rust-raqote-0.8.5
  (crate-source "raqote" "0.8.5"
                "00w9xc0aydscjk03z2ipjwr51g9h813qnbhbsg6gjp9ain2r0j9j"))

(define rust-ratatui-0.30.0
  (crate-source "ratatui" "0.30.0"
                "1g36h96fnr8ay7bmwplxsfa5xzsp0pdaxny8s5a68i54igxngkni"))

(define rust-ratatui-core-0.1.0
  (crate-source "ratatui-core" "0.1.0"
                "14y2pv5njy7kpzjsfn20a8vmjbhnfq5vgbgppxrszjljkahdxy2y"))

(define rust-ratatui-crossterm-0.1.0
  (crate-source "ratatui-crossterm" "0.1.0"
                "1cslvh75a29gdmz84s5sjaqd61k4s0fkjsjwn8gi4k1bcngrnz2p"))

(define rust-ratatui-termwiz-0.1.0
  (crate-source "ratatui-termwiz" "0.1.0"
                "0p2l7pymlcfv9n802pd32m604m145rrpc5hv6bq9ahpds05zwxhg"))

(define rust-ratatui-wgpu-0.5.0
  (crate-source "ratatui-wgpu" "0.5.0"
                "0kgilafvxgm5j5lqs26v7s940whphawii21lay75xrl05ca6cx1h"))

(define rust-ratatui-widgets-0.3.0
  (crate-source "ratatui-widgets" "0.3.0"
                "1nqjcrskazvfgjkmmsifliqrvap8bw6850rlap109rnl7h1gmnyp"))

(define rust-recvmsg-1.0.0
  (crate-source "recvmsg" "1.0.0"
                "0xa173gbg1cx8q7wyzi6c4kmcsz5rka68r4jb6kg14icskax9vfk"))

(define rust-redox-syscall-0.7.5
  (crate-source "redox_syscall" "0.7.5"
                "06qvcqy42dv563dsbxpxyig0mslwrhyx3xllknqyl4l41nka2rj6"))

(define rust-relative-path-2.0.1
  (crate-source "relative-path" "2.0.1"
                "1c4jm6x0p88722c77xx53mb7zcs4xznp9d3whdsbmn1248qhm95w"))

(define rust-renderdoc-sys-1.1.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "renderdoc-sys" "1.1.0"
                "0cj8zjs7k0gvchcx3jhpg8r9bbqy8b1hsgbz0flcq2ydn12hmcqr"))

(define rust-rquickjs-0.11.0
  (crate-source "rquickjs" "0.11.0"
                "0yn708px5v56bxjb9a7cy2xa55vlhq2zg73nnknkkhw7qpbcc3f5"))

(define rust-rquickjs-core-0.11.0
  (crate-source "rquickjs-core" "0.11.0"
                "1h8hwc3kbskwcah34ikzrmsqqm4mzfd2lx8fn8x1qcjw5107igxq"))

(define rust-rquickjs-macro-0.11.0
  (crate-source "rquickjs-macro" "0.11.0"
                "101bmmzjd34pyg25sarnnvs81f20lkhi6slh0jqpfmhsyigj21ki"))

(define rust-rquickjs-serde-0.5.0
  (crate-source "rquickjs-serde" "0.5.0"
                "08zb3dbflfdy0zmqr9kw53q1yjdik8vmwzl8ap2wa75xr1c24f79"))

(define rust-rquickjs-sys-0.11.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "rquickjs-sys" "0.11.0"
                "10wx5fzfka3d558kqpq94a0m37z9wywyrqd4ss10wii7xw0lcd17"))

(define rust-rustc-hash-1.1.0
  (crate-source "rustc-hash" "1.1.0"
                "1qkc5khrmv5pqi5l5ca9p5nl5hs742cagrndhbrlk3dhlrx3zm08"))

(define rust-rustix-openpty-0.2.0
  (crate-source "rustix-openpty" "0.2.0"
                "14r3bvc2rcvvpdmhjivl6bqifdcl23f8bw9ncc58faw9b5y6rq8x"))

(define rust-rustls-native-certs-0.8.3
  (crate-source "rustls-native-certs" "0.8.3"
                "0qrajg2n90bcr3bcq6j95gjm7a9lirfkkdmjj32419dyyzan0931"))

(define rust-rustls-platform-verifier-0.6.2
  (crate-source "rustls-platform-verifier" "0.6.2"
                "110pqkn3px9115pb6h6a23cq738v29gbp559dfvpmbibqzmzx68x"))

(define rust-rustls-platform-verifier-android-0.1.1
  (crate-source "rustls-platform-verifier-android" "0.1.1"
                "13vq6sxsgz9547xm2zbdxiw8x7ad1g8n8ax6xvxsjqszk7q6awgq"))

(define rust-sctk-adwaita-0.10.1
  (crate-source "sctk-adwaita" "0.10.1"
                "1v14vqp7k39jk7pgaibwc06qq9vcmi82k7zlv3qpfvq52w17y9xn"))

(define rust-self-cell-1.2.2
  (crate-source "self_cell" "1.2.2"
                "12cdmh9p2h72rmw923kj841jji4k0vrykihvx19fn059az8pcbmi"))

(define rust-seq-macro-0.3.6
  (crate-source "seq-macro" "0.3.6"
                "1k4sshn0x2i6a9g97sy5jl7ghlqgmmh3n76aj3rrjwxy1x0i3iqv"))

(define rust-serial2-0.2.36
  (crate-source "serial2" "0.2.36"
                "1wqj7kr53n56zbrnb4jrsw9km1hd9z5spdf2ivac6bl8ldmc9nzw"))

(define rust-spirv-0.3.0+sdk-1.3.268.0
  (crate-source "spirv" "0.3.0+sdk-1.3.268.0"
                "0i3qj7yvvprai1s03dvll2gkfy8398nl64wvllkhaaa4vh1i197d"))

(define rust-streaming-iterator-0.1.9
  (crate-source "streaming-iterator" "0.1.9"
                "0845zdv8qb7zwqzglpqc0830i43xh3fb6vqms155wz85qfvk28ib"))

(define rust-strict-num-0.1.1
  (crate-source "strict-num" "0.1.1"
                "0cb7l1vhb8zj90mzm8avlk815k40sql9515s865rqdrdfavvldv6"))

(define rust-strum-0.27.2
  (crate-source "strum" "0.27.2"
                "1ksb9jssw4bg9kmv9nlgp2jqa4vnsa3y4q9zkppvl952q7vdc8xg"))

(define rust-strum-macros-0.27.2
  (crate-source "strum_macros" "0.27.2"
                "19xwikxma0yi70fxkcy1yxcv0ica8gf3jnh5gj936jza8lwcx5bn"))

(define rust-sw-composite-0.7.16
  (crate-source "sw-composite" "0.7.16"
                "1m3i4vdmixzcsnbffiws8jimsxdq1n3346kkmmha1bxljmwgpj4s"))

(define rust-syntect-5.3.0
  (crate-source "syntect" "5.3.0"
                "09f9j0hlsz5zmc0fkjdp64sjnyzcvp86pvxfk51p19cmbp04asv5"))

(define rust-tap-1.0.1
  (crate-source "tap" "1.0.1"
                "0sc3gl4nldqpvyhqi3bbd0l9k7fngrcl4zs47n314nqqk4bpx4sm"))

(define rust-tar-0.4.46
  (crate-source "tar" "0.4.46"
                "0h68bc0y1nma3h2ypj28vxc84msjydlrj8rviqwphg00lvcj2qiz"))

(define rust-tiny-http-0.12.0
  (crate-source "tiny_http" "0.12.0"
                "10nw9kk2i2aq4l4csy0825qkq0l66f9mz2c1n57yg8hkckgib69q"))

(define rust-tiny-keccak-2.0.2
  (crate-source "tiny-keccak" "2.0.2"
                "0dq2x0hjffmixgyf6xv9wgsbcxkd65ld0wrfqmagji8a829kg79c"))

(define rust-tiny-skia-0.11.4
  (crate-source "tiny-skia" "0.11.4"
                "1aq9gd4qh4418g8v08qzakqqggx8hl66qcianl3k5bjdsja37lc3"))

(define rust-tiny-skia-path-0.11.4
  (crate-source "tiny-skia-path" "0.11.4"
                "14ywbdfakvacl6rxxmzbnycplaxpc6i2linh2yqk0sp8qb07z7lw"))

(define rust-toml-0.8.23
  (crate-source "toml" "0.8.23"
                "0qnkrq4lm2sdhp3l6cb6f26i8zbnhqb7mhbmksd550wxdfcyn6yw"))

(define rust-toml-datetime-0.6.11
  (crate-source "toml_datetime" "0.6.11"
                "077ix2hb1dcya49hmi1avalwbixmrs75zgzb3b2i7g2gizwdmk92"))

(define rust-toml-edit-0.20.7
  (crate-source "toml_edit" "0.20.7"
                "10bdyrl1yj5jxkiqfa2fyx9inlzlm7s8nf1jnysp4k6qwky2gx3h"))

(define rust-toml-edit-0.22.27
  (crate-source "toml_edit" "0.22.27"
                "16l15xm40404asih8vyjvnka9g0xs9i4hfb6ry3ph9g419k8rzj1"))

(define rust-toml-write-0.1.2
  (crate-source "toml_write" "0.1.2"
                "008qlhqlqvljp1gpp9rn5cqs74gwvdgbvs92wnpq8y3jlz4zi6ax"))

(define rust-trash-5.2.6
  (crate-source "trash" "5.2.6"
                "0ikg6n5844014rj90fq6lbpkjh49qzxijwliihmdkhkfsv3y00kn"))

(define rust-tree-magic-mini-3.2.2
  (crate-source "tree_magic_mini" "3.2.2"
                "19nm2hkspb8p4gxgk442b1hmbbh9l5fnf7w3nli6rfhw0s85nxmq"))

(define rust-tree-sitter-0.26.8
  (crate-source "tree-sitter" "0.26.8"
                "0f055nmpkl9aq8pifkb4m5bglsb1cqrj5klf1lz5wb2qs2ax8yw8"))

(define rust-tree-sitter-go-0.25.0
  (crate-source "tree-sitter-go" "0.25.0"
                "1shnigi37lrq88b93i1vnha62byy1nykrq62sbac0p435x6hlmn8"))

(define rust-tree-sitter-highlight-0.26.8
  (crate-source "tree-sitter-highlight" "0.26.8"
                "1q57a8bl6qzh3mg6n6cvyyddaf5dm6i9c960d4z32n2blda2ppnc"))

(define rust-tree-sitter-javascript-0.25.0
  (crate-source "tree-sitter-javascript" "0.25.0"
                "1xckcrssvg8479aym090rgyjdakhqkshbrh6vw5sj9q6phm4y838"))

(define rust-tree-sitter-json-0.24.8
  (crate-source "tree-sitter-json" "0.24.8"
                "0wf4gsa5mcrcprg8wh647n76rwv4cx8kbky6zw605h06lk67lwjd"))

(define rust-tree-sitter-language-0.1.7
  (crate-source "tree-sitter-language" "0.1.7"
                "10hpwqd45v529p1q23d11k8wms7zifyda5s9yl7xa36ca3qr9680"))

(define rust-tree-sitter-templ-2.2.0
  (crate-source "tree-sitter-templ" "2.2.0"
                "06c6dmh684hjva37zp0ifdz7m9ahqz9a6lyclyjkiwiaxdv6y846"))

(define rust-tree-sitter-typescript-0.23.2
  (crate-source "tree-sitter-typescript" "0.23.2"
                "1zsyaxx3v1sd8gx2zkscwv6z1sq2nvccqpvd8k67ayllipnpcpvc"))

(define rust-ts-rs-12.0.1
  (crate-source "ts-rs" "12.0.1"
                "1n1if87wnpdg3p7gzibkn0l79cax29cgbaallm3isaarcq350q3m"))

(define rust-ts-rs-macros-12.0.1
  (crate-source "ts-rs-macros" "12.0.1"
                "1ajjnsl39fz492mrqpjkkrrh8s5shl5ghjv7kvpqhydwa7m0xn9q"))

(define rust-typed-path-0.12.3
  (crate-source "typed-path" "0.12.3"
                "03k051dafrnyg3lbm4c85zg0mpfhbn6l9aq4ryq8yyy8h2dzha4f"))

(define rust-typenum-1.20.0
  (crate-source "typenum" "1.20.0"
                "1pj35y6q11d3y55gdl6g1h2dfhmybjming0jdi9bh0bpnqm11kj0"))

(define rust-unicode-id-start-1.4.0
  (crate-source "unicode-id-start" "1.4.0"
                "01v0ig6a5dy75r9wwhnjfw1fzcj3nhcqj3q2c11dw6aykg99mdw1"))

(define rust-ureq-3.3.0
  (crate-source "ureq" "3.3.0"
                "1h6gmx5kbafh4vn1dbypc01m5gy9imja2n0vxd74v1nmvjf119yy"))

(define rust-ureq-proto-0.6.0
  (crate-source "ureq-proto" "0.6.0"
                "1340ga8p9qi70c0vdrwg21h1fp4ai7pvfy18z461n6xxn22bm579"))

(define rust-urlencoding-2.1.3
  (crate-source "urlencoding" "2.1.3"
                "1nj99jp37k47n0hvaz5fvz7z6jd0sb4ppvfy3nphr1zbnyixpy6s"))

(define rust-vt100-0.16.2
  (crate-source "vt100" "0.16.2"
                "1nbgsgamgibyx6y4xiyk6nkz7zggzbs6s445wq4yd0zsp1gzfkq5"))

(define rust-vte-0.15.0
  (crate-source "vte" "0.15.0"
                "1g9xgnw7q7zdwgfqa6zfcfsp92wn0j0h13kzsqy0dq3c80c414m5"))

(define rust-wasip2-1.0.3+wasi-0.2.9
  (crate-source "wasip2" "1.0.3+wasi-0.2.9"
                "1mi3w855dz99xzjqc4aa8c9q5b6z1y5c963pkk4cvmr6vdr4c1i0"))

(define rust-wasm-bindgen-0.2.120
  (crate-source "wasm-bindgen" "0.2.120"
                "1cax9wy1n67sa2m16ia72lsxdrc5pzcv47psxp4p833yp3cvclnz"))

(define rust-wasm-bindgen-futures-0.4.70
  (crate-source "wasm-bindgen-futures" "0.4.70"
                "1130a64yig0p10mk7rnq5l2jpwglbyxpnqg6h0nlqwzcmir4i4xg"))

(define rust-wasm-bindgen-macro-0.2.120
  (crate-source "wasm-bindgen-macro" "0.2.120"
                "00xixpydzjd6y9knwdsrsiff6wi1ddszb1fa9bk25csz94gh9cbq"))

(define rust-wasm-bindgen-macro-support-0.2.120
  (crate-source "wasm-bindgen-macro-support" "0.2.120"
                "0h8v5aphaaq155fzz2d312zrxbka1x6lsvb8mhc8m60n0kr0zkcx"))

(define rust-wasm-bindgen-shared-0.2.120
  (crate-source "wasm-bindgen-shared" "0.2.120"
                "1sjrac4f4j5pgw42mxadq9v42f0bji1a2rcksrbnrwgbh8y7nxa9"))

(define rust-web-sys-0.3.97
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.97"
                "00knh8cizgb01bmh362f3f19b11f8zl1y3gj6h47pk95233vmb9f"))

(define rust-webpki-root-certs-1.0.7
  (crate-source "webpki-root-certs" "1.0.7"
                "0b59x5mzsilk42w59nif3lfhc24pgzb0v35pi6p01qy37z7424gk"))

(define rust-wgpu-28.0.0
  (crate-source "wgpu" "28.0.0"
                "17ypgaygh18pzvf2b9jm92wylq4ywbd4rwrm25yrq47xbx6m7jzr"))

(define rust-wgpu-core-28.0.1
  (crate-source "wgpu-core" "28.0.1"
                "1y8h3i6ydjwhddliivqs220nc7jd2ymihcidzpf6lrizym14cgyj"))

(define rust-wgpu-core-deps-apple-28.0.0
  (crate-source "wgpu-core-deps-apple" "28.0.0"
                "1nj7024j30plwhqqmfijg2ik42h8ahj194xzhv23gwqqp6bbddw7"))

(define rust-wgpu-core-deps-emscripten-28.0.0
  (crate-source "wgpu-core-deps-emscripten" "28.0.0"
                "0ydxim2s0krqfhdyxmsxm4i2c4a5maillg6y8z0ylkzq671m3cil"))

(define rust-wgpu-core-deps-windows-linux-android-28.0.0
  (crate-source "wgpu-core-deps-windows-linux-android" "28.0.0"
                "1bmszr0aw4nsvhh0k4h9whaaa53zrvv83qj3n979djdjf9p9gjk8"))

(define rust-wgpu-hal-28.0.1
  (crate-source "wgpu-hal" "28.0.1"
                "1sqfqb5619bx80kzp6vqca972gwpkmkwxqf9vhj8h8gb9d3wpmj4"))

(define rust-wgpu-types-28.0.0
  (crate-source "wgpu-types" "28.0.0"
                "0344ym97a5mhn7ha4clxh61schlw2dmb3nyx4z6x4kjrgrshi0z1"))

(define rust-which-8.0.6
  (crate-source "which" "8.0.6"
                "0kq3r101j662briq4hrlrd9jv090ppsr3k0smcf7lr0np2rg5qms"))

(define rust-widestring-1.2.1
  (crate-source "widestring" "1.2.1"
                "0wg4qdbs70xqnlbm8wb0bs4idm2mxk3b6kaqwllsncmb2cqrq1kj"))

(define rust-windows-0.56.0
  (crate-source "windows" "0.56.0"
                "0cp10nzrqgrlk91dpwxjcpzyy6imr5vxr5f898pss7nz3gq9vrhx"))

(define rust-windows-core-0.56.0
  (crate-source "windows-core" "0.56.0"
                "19pj57bm0rzhlk0ghrccd3i5zvh0ghm52f8cmdc8d3yhs8pfb626"))

(define rust-windows-implement-0.56.0
  (crate-source "windows-implement" "0.56.0"
                "16rgkvlx4syqmajfdwmkcvn6nvh126wjj8sg3jvsk5fdivskbz7n"))

(define rust-windows-interface-0.56.0
  (crate-source "windows-interface" "0.56.0"
                "1k2prfxna0mw47f8gi8qhw9jfpw66bh2cqzs67sgipjfpx30b688"))

(define rust-windows-result-0.1.2
  (crate-source "windows-result" "0.1.2"
                "1y274q1v0vy21lhkgslpxpq1m08hvr1mcs2l88h1b1gcx0136f2y"))

(define rust-winnow-1.0.2
  (crate-source "winnow" "1.0.2"
                "1l7xnfvlgy4da6gq5ip2bgcm8i9d0rwzaxg1p88nlw8lxy5p1q9f"))

(define rust-winresource-0.1.31
  (crate-source "winresource" "0.1.31"
                "11v0hr6kfyi8kl8am96fkn325bjinjgs77ixzvjd7dw6snqsi1h9"))

(define rust-wl-clipboard-rs-0.9.3
  (crate-source "wl-clipboard-rs" "0.9.3"
                "18xh5q3r9k57v3g2565vr33irldjh99p29x1ydpdk1rfldqi8rg9"))

(define rust-wyz-0.5.1
  (crate-source "wyz" "0.5.1"
                "1vdrfy7i2bznnzjdl9vvrzljvs4s3qm8bnlgqwln6a941gy61wq5"))

(define rust-xattr-1.6.1
  (crate-source "xattr" "1.6.1"
                "0ml1mb43gqasawillql6b344m0zgq8mz0isi11wj8vbg43a5mr1j"))

(define rust-xz2-0.1.7
  (crate-source "xz2" "0.1.7"
                "1qk7nzpblizvayyq4xzi4b0zacmmbqr6vb9fc0v1avyp17f4931q"))

(define rust-yaml-rust-0.4.5
  (crate-source "yaml-rust" "0.4.5"
                "118wbqrr4n6wgk5rjjnlrdlahawlxc1bdsx146mwk8f79in97han"))

(define rust-zip-9.0.3
  (crate-source "zip" "9.0.3"
                "0wf9mm5zbdbdzw3xakjif9bqmvr98h4pl6ik4pjlma0jnrhqbnf2"))

(define rust-zopfli-0.8.3
  (crate-source "zopfli" "0.8.3"
                "0jaj5dyh3mks0805h4ldrsh5pwq4i2jc9dc9zwjm91k3gmwxhp7h"))


(define rust-addr2line-0.17.0
  (crate-source "addr2line" "0.17.0"
                "0sw16zqy6w0ar633z69m7lw6gb0k1y7xj3387a8wly43ij5div5r"))

(define rust-adler-1.0.2
  (crate-source "adler" "1.0.2"
                "1zim79cvzd5yrkzl3nyfx0avijwgk9fqv3yrscdy1cc79ih02qpj"))

(define rust-ahash-0.8.11
  (crate-source "ahash" "0.8.11"
                "04chdfkls5xmhp1d48gnjsmglbqibizs3bpbj6rsj604m10si7g8"))

(define rust-aho-corasick-0.7.20
  (crate-source "aho-corasick" "0.7.20"
                "1b3if3nav4qzgjz9bf75b2cv2h2yisrqfs0np70i38kgz4cn94yc"))

(define rust-aho-corasick-1.0.1
  (crate-source "aho-corasick" "1.0.1"
                "014ddyrlbwg18m74fa52wrfik8y3pzhwqg811yvsyc8cjb70iz37"))

(define rust-ambient-authority-0.0.2
  (crate-source "ambient-authority" "0.0.2"
                "0fxsfyhy64jx7zrkb85h1vhr5nfqncja3pwpikid471d8w6yxm79"))

(define rust-android-tzdata-0.1.1
  (crate-source "android-tzdata" "0.1.1"
                "1w7ynjxrfs97xg3qlcdns4kgfpwcdv824g611fq32cag4cdr96g9"))

(define rust-ansi-term-0.12.1
  (crate-source "ansi_term" "0.12.1"
                "1ljmkbilxgmhavxvxqa7qvm6f3fjggi7q2l3a72q9x0cxjvrnanm"))

(define rust-anyhow-1.0.95
  (crate-source "anyhow" "1.0.95"
                "010vd1ki8w84dzgx6c81sc8qm9n02fxic1gkpv52zp4nwrn0kb1l"))

(define rust-arc-swap-1.5.0
  (crate-source "arc-swap" "1.5.0"
                "07sb99f18spqmjx7f4cmqx7hc8ayspcmw9shl4zjvf300ki8rmy5"))

(define rust-async-channel-1.8.0
  (crate-source "async-channel" "1.8.0"
                "0cv8ha6y7s6scsgjipn7ciybry9g57rklw8404igrksw7vlgwing"))

(define rust-async-trait-0.1.80
  (crate-source "async-trait" "0.1.80"
                "1jip2xkv8l67bbg6jrz3b1sdb7api77vy38wrjl7sfkmya3j1yn6"))

(define rust-atomic-waker-1.0.0
  (crate-source "atomic-waker" "1.0.0"
                "0ansiq5vlw684fhks2x4a4is2rqlbv50q5mi8x0fxxvx5q2p8lq6"))

(define rust-autocfg-1.1.0
  (crate-source "autocfg" "1.1.0"
                "1ylp3cb47ylzabimazvbz9ms6ap784zhb6syaz6c1jqpmcmq0s6l"))

(define rust-aws-lc-rs-1.16.2
  (crate-source "aws-lc-rs" "1.16.2"
                "1z6i8qs0xjnzvslxnkhvywzzwfkafb1s4nrpg3f2k1nii4i92m50"))

(define rust-aws-lc-sys-0.39.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "aws-lc-sys" "0.39.0"
                "02jga4605vwqcxzd4k3ikd01x27k4gqwd8hh2rs7qm2w9hmfb9qz"))

(define rust-axum-0.8.4
  (crate-source "axum" "0.8.4"
                "1d99kb3vcjnhbgrf6hysllf25hzagw7m1i1nidjpgsaa30n8c7h2"))

(define rust-axum-core-0.5.2
  (crate-source "axum-core" "0.5.2"
                "19kwzksb4hwr3qfbrhjbqf83z6fjyng14wrkzck6fj1g8784qik8"))

(define rust-axum-extra-0.10.1
  (crate-source "axum-extra" "0.10.1"
                "0gbi6p5944rfm545cml8ns2i23yl0nrjarbm7iyin4zm64w4dgs5"))

(define rust-axum-server-0.7.2
  (crate-source "axum-server" "0.7.2"
                "1azq83vhnwl3c8b7cvgrp9md02kahjjlmrxniwz0kw3d1pv0ap29"))

(define rust-backtrace-0.3.65
  (crate-source "backtrace" "0.3.65"
                "0qggp0d8pbw5vfnpm0r7lrn6wmh5yjiz4yc4bzynb8l26i2pv88i"))

(define rust-backtrace-ext-0.2.1
  (crate-source "backtrace-ext" "0.2.1"
                "0l4xacjnx4jrn9k14xbs2swks018mviq03sp7c1gn62apviywysk"))

(define rust-base64-0.13.0
  (crate-source "base64" "0.13.0"
                "1z82g23mbzjgijkpcrilc7nljpxpvpf7zxf6iyiapkgka2ngwkch"))

(define rust-bstr-1.5.0
  (crate-source "bstr" "1.5.0"
                "1xafaq57fzwa38yjwdzvqlbm8h207sjm585y4kdxjv1znj5ycim2"))

(define rust-bumpalo-3.16.0
  (crate-source "bumpalo" "3.16.0"
                "0b015qb4knwanbdlp1x48pkb4pm57b8gidbhhhxr900q2wb6fabr"))

(define rust-byteorder-1.4.3
  (crate-source "byteorder" "1.4.3"
                "0456lv9xi1a5bcm32arknf33ikv76p3fr9yzki4lb2897p2qkh8l"))

(define rust-cap-fs-ext-3.4.4
  (crate-source "cap-fs-ext" "3.4.4"
                "0g0pdhz3w09pdza8xamzrzicjpmwk73y7h8mdzxfhgqra62w2774"))

(define rust-cap-primitives-3.4.4
  (crate-source "cap-primitives" "3.4.4"
                "0apni9ybd60z3d2zzbwv3c57zghd0464r7gm4syghfags573j7ha"))

(define rust-cap-rand-3.4.4
  (crate-source "cap-rand" "3.4.4"
                "0h0vjjmdwpf0139y1silf84frkps1mix1280y21qd8lqyz68kjqa"))

(define rust-cap-std-3.4.4
  (crate-source "cap-std" "3.4.4"
                "12a1k1633flbznkfzjg3xmhkh5l4ss4j9hf3fvqmipc3lmf3bh07"))

(define rust-cap-time-ext-3.4.4
  (crate-source "cap-time-ext" "3.4.4"
                "0nqskcskhki1chj3ylln333nh0xrbp3phsa6l3d8a03pp0hga6j9"))

(define rust-castaway-0.1.2
  (crate-source "castaway" "0.1.2"
                "1xhspwy477qy5yg9c3jp713asxckjpx0vfrmz5l7r5zg7naqysd2"))

(define rust-cfg-if-1.0.0
  (crate-source "cfg-if" "1.0.0"
                "1za0vb97n4brpzpv8lsbnzmq5r8f2b0cpqqr0sy8h5bn751xxwds"))

(define rust-chrono-0.4.39
  (crate-source "chrono" "0.4.39"
                "09g8nf409lb184kl9j4s85k0kn8wzgjkp5ls9zid50b886fwqdky"))

(define rust-clap-3.2.4
  (crate-source "clap" "3.2.4"
                "0yn861xzwxwsfdl3xa6pamvcqs8pm904z0ipg2hlbyxl74vxw83d"))

(define rust-clap-complete-3.2.1
  (crate-source "clap_complete" "3.2.1"
                "0h6z59gxzkyyrz15f52kwsb4n82mlwqcn1zs5lqz1r15bymvlvhg"))

(define rust-clap-derive-3.2.4
  (crate-source "clap_derive" "3.2.4"
                "1xwqpyjqqffdyy5ddbdziij6j3pgg29yq0k0hcrd7ywzp04aysq2"))

(define rust-clap-lex-0.2.2
  (crate-source "clap_lex" "0.2.2"
                "04rn568mpbc4smk1wlsh9ky4z12b53rgiv6g6i1fpssh0ikcsf2m"))

(define rust-close-fds-0.3.2
  (crate-source "close_fds" "0.3.2"
                "1vd2i1gkvfcgdlzgrkgivhx3ky0zs98g8q3mwmwrxmg97pridi1v"))

(define rust-cmake-0.1.54
  (crate-source "cmake" "0.1.54"
                "1w41ma28yzad9x757s9sfq1wigjs9j902hbzc0nbxpc9vvws7jp7"))

(define rust-colored-2.0.0
  (crate-source "colored" "2.0.0"
                "1gbcijscmznzy42rn213yp9ima7210zakgaqibgg1n441dsnyqdk"))

(define rust-colorsys-0.6.5
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "colorsys" "0.6.5"
                "0w5vvcq3497m184a399x2rh9fgmarwzdkjc87zzmasslklbzkzad"))

(define rust-concurrent-queue-2.2.0
  (crate-source "concurrent-queue" "2.2.0"
                "0z0bnpgcblhrms6gph7x78yplj3qmlr5mvl38v9641zsxiqngv32"))

(define rust-console-0.15.0
  (crate-source "console" "0.15.0"
                "0c9wif28i3q231gvjprqdq1glmgmmcdxpmxcwk1p0jx45k9k52x2"))

(define rust-cookie-0.18.1
  (crate-source "cookie" "0.18.1"
                "0iy749flficrlvgr3hjmf3igr738lk81n5akzf4ym4cs6cxg7pjd"))

(define rust-cpufeatures-0.2.2
  (crate-source "cpufeatures" "0.2.2"
                "0jsyrw41g5sqdpc9jgk57969hc0xw4c52j9amvmll4mbcwb019jr"))

(define rust-crossbeam-0.8.1
  (crate-source "crossbeam" "0.8.1"
                "0ibq943sxbli0d03aihys3n4l9apy88d22z9759b0g1wdf7miraa"))

(define rust-crossbeam-channel-0.5.4
  (crate-source "crossbeam-channel" "0.5.4"
                "0lvcpv6hg1g1r6aamiq9b4958p4hjy8dsqzrnmj6hp36zgappajs"))

(define rust-crossbeam-deque-0.8.1
  (crate-source "crossbeam-deque" "0.8.1"
                "07nypn86id2lf912ahiww1jvqp0zbk2xa25ra7vzplph375c0mb4"))

(define rust-crossbeam-epoch-0.9.8
  (crate-source "crossbeam-epoch" "0.9.8"
                "137ydqj18qddmazgqd16kjn766byixinmavra1hs0src389wyi8i"))

(define rust-crossbeam-queue-0.3.5
  (crate-source "crossbeam-queue" "0.3.5"
                "18kpa83m1ivz3230f4ax95f9pgcclj227rg4y1w5fyja1x0dh98z"))

(define rust-crossbeam-utils-0.8.15
  (crate-source "crossbeam-utils" "0.8.15"
                "0jwq8srmjcwvq9q883k9zyb26qqznaj4jjqdxmvw7xcmrkc3q1iw"))

(define rust-crypto-common-0.1.6
  (crate-source "crypto-common" "0.1.6"
                "1cvby95a6xg7kxdz5ln3rl9xh66nz66w46mm3g56ri1z5x815yqv"))

(define rust-ctor-0.1.22
  (crate-source "ctor" "0.1.22"
                "1712zdlrmcfkfw38dkj67xg72fd0p9slyqqi64c6n94zgi7vwxzq"))

(define rust-curl-0.4.44
  (crate-source "curl" "0.4.44"
                "08hsq6ssy228df56adv2wbgam05f5rw1f2wzs7mhkb678qbx36sh"))

(define rust-curl-sys-0.4.68+curl-8.4.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "curl-sys" "0.4.68+curl-8.4.0"
                "0bvmslw0g3hhdgws8jhxzj7jamsy5f1kq9xj2r5kf3ini26x385l"))

(define rust-daemonize-0.5.0
  (crate-source "daemonize" "0.5.0"
                "0vhikx85f85r46xghsb4avsv6ww8mz9lipqvsia7m21wrfmgv2xb"))

(define rust-data-encoding-2.9.0
  (crate-source "data-encoding" "2.9.0"
                "0xm46371aw613ghc12ay4vsnn49hpcmcwlijnqy8lbp2bpd308ra"))

(define rust-derivative-2.2.0
  (crate-source "derivative" "2.2.0"
                "02vpb81wisk2zh1d5f44szzxamzinqgq2k8ydrfjj2wwkrgdvhzw"))

(define rust-dialoguer-0.10.4
  (crate-source "dialoguer" "0.10.4"
                "11rgzrhi677w9gf1r3ip2x361svdkjkr2m5dsfca9fcljacg5ijr"))

(define rust-directories-5.0.1
  (crate-source "directories" "5.0.1"
                "0dba6xzk79s1clqzxh2qlgzk3lmvvks1lzzjhhi3hd70hhxifjcs"))

(define rust-dirs-4.0.0
  (crate-source "dirs" "4.0.0"
                "0n8020zl4f0frfnzvgb9agvk4a14i1kjz4daqnxkgslndwmaffna"))

(define rust-dirs-sys-0.3.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "dirs-sys" "0.3.7"
                "19md1cnkazham8a6kh22v12d8hh3raqahfk6yb043vrjr68is78v"))

(define rust-dirs-sys-0.4.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "dirs-sys" "0.4.1"
                "071jy0pvaad9lsa6mzawxrh7cmr7hsmsdxwzm7jzldfkrfjha3sj"))

(define rust-dissimilar-1.0.6
  (crate-source "dissimilar" "1.0.6"
                "0phdkg9d9c1vmn5v74lq7rmaba2m52fkwcryd3cbw46pww5cc3i1"))

(define rust-doctest-file-1.0.0
  (crate-source "doctest-file" "1.0.0"
                "0qkmnrsx2kszm58wxyry63bs35msj9chdb6jlh54a8cdwaiizj5a"))

(define rust-either-1.6.1
  (crate-source "either" "1.6.1"
                "0mwl9vngqf5jvrhmhn9x60kr5hivxyjxbmby2pybncxfqhf4z3g7"))

(define rust-embed-resource-3.0.6
  (crate-source "embed-resource" "3.0.6"
                "0bm02623nhwb5k2yp0rgk5imhqwhg6y9mvnp70052r1wazy7b82m"))

(define rust-encode-unicode-0.3.6
  (crate-source "encode_unicode" "0.3.6"
                "07w3vzrhxh9lpjgsg2y5bwzfar2aq35mdznvcp3zjl0ssj7d4mx3"))

(define rust-encoding-rs-0.8.34
  (crate-source "encoding_rs" "0.8.34"
                "0nagpi1rjqdpvakymwmnlxzq908ncg868lml5b70n08bm82fjpdl"))

(define rust-equivalent-1.0.1
  (crate-source "equivalent" "1.0.1"
                "1malmx5f4lkfvqasz319lq6gb3ddg19yzf9s8cykfsgzdmyq0hsl"))

(define rust-erased-serde-0.3.20
  (crate-source "erased-serde" "0.3.20"
                "1zbzqr50vj05q0gphygrwls4pldaj4qwp1kxils4ddfhs3c2s4xd"))

(define rust-errno-0.3.10
  (crate-source "errno" "0.3.10"
                "0pgblicz1kjz9wa9m0sghkhh2zw1fhq1mxzj7ndjm746kg5m5n1k"))

(define rust-event-listener-2.5.2
  (crate-source "event-listener" "2.5.2"
                "0wgbyhw4piqrrln6s61y3sc06wd3liwzzz18hazji3wk2ya31wvp"))

(define rust-expect-test-1.4.1
  (crate-source "expect-test" "1.4.1"
                "1lzqx5hqh1g4llzqby4z1d18xmrjjx63c5l0na7ycf6mmpzfmn9h"))

(define rust-fastrand-1.7.0
  (crate-source "fastrand" "1.7.0"
                "1pvci54f2cm69ybc308z213xdybgqpvf2pcvq1kch69mwp7g1z63"))

(define rust-fastrand-2.1.0
  (crate-source "fastrand" "2.1.0"
                "06p5d0rxq7by260m4ym9ial0bwgi0v42lrvhl6nm2g7h0h2m3h4z"))

(define rust-fd-lock-4.0.2
  (crate-source "fd-lock" "4.0.2"
                "0ixrsd19k2cpl773p9hd0yk3hac684d9aphbxy0jq9q64bd6hmvy"))

(define rust-file-id-0.2.2
  (crate-source "file-id" "0.2.2"
                "0dmylm34z6g8cg3b60sc6bk9v5wv9930vyx9wgcdpjpgpfwh9jbb"))

(define rust-filetime-0.2.25
  (crate-source "filetime" "0.2.25"
                "11l5zr86n5sr6g6k6sqldswk0jzklm0q95rzikxcns0yk0p55h1m"))

(define rust-foldhash-0.1.4
  (crate-source "foldhash" "0.1.4"
                "0vsxw2iwpgs7yy6l7pndm7b8nllaq5vdxwnmjn1qpm5kyzhzvlm0"))

(define rust-form-urlencoded-1.2.1
  (crate-source "form_urlencoded" "1.2.1"
                "0milh8x7nl4f450s3ddhg57a3flcv6yq8hlkyk6fyr3mcb128dp1"))

(define rust-fs-err-3.1.0
  (crate-source "fs-err" "3.1.0"
                "1al2sj8src02wwww70vv2gypsrs6wyzx6zlpk82h84m2qajbv28z"))

(define rust-fs-extra-1.3.0
  (crate-source "fs_extra" "1.3.0"
                "075i25z70j2mz9r7i9p9r521y8xdj81q7skslyb7zhqnnw33fw22"))

(define rust-fs-set-times-0.20.1
  (crate-source "fs-set-times" "0.20.1"
                "1yxqkl8khk1593ribn4s9v60vf375gi9sgw9hq6nk5svf9yk6fq3"))

(define rust-fsevent-sys-4.1.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "fsevent-sys" "4.1.0"
                "1liz67v8b0gcs8r31vxkvm2jzgl9p14i78yfqx81c8sdv817mvkn"))

(define rust-futures-0.3.31
  (crate-source "futures" "0.3.31"
                "0xh8ddbkm9jy8kc5gbvjp9a4b6rqqxvc8471yb2qaz5wm2qhgg35"))

(define rust-futures-channel-0.3.31
  (crate-source "futures-channel" "0.3.31"
                "040vpqpqlbk099razq8lyn74m0f161zd0rp36hciqrwcg2zibzrd"))

(define rust-futures-core-0.3.31
  (crate-source "futures-core" "0.3.31"
                "0gk6yrxgi5ihfanm2y431jadrll00n5ifhnpx090c2f2q1cr1wh5"))

(define rust-futures-executor-0.3.31
  (crate-source "futures-executor" "0.3.31"
                "17vcci6mdfzx4gbk0wx64chr2f13wwwpvyf3xd5fb1gmjzcx2a0y"))

(define rust-futures-io-0.3.31
  (crate-source "futures-io" "0.3.31"
                "1ikmw1yfbgvsychmsihdkwa8a1knank2d9a8dk01mbjar9w1np4y"))

(define rust-futures-lite-1.13.0
  (crate-source "futures-lite" "1.13.0"
                "1kkbqhaib68nzmys2dc8j9fl2bwzf2s91jfk13lb2q3nwhfdbaa9"))

(define rust-futures-macro-0.3.31
  (crate-source "futures-macro" "0.3.31"
                "0l1n7kqzwwmgiznn0ywdc5i24z72zvh9q1dwps54mimppi7f6bhn"))

(define rust-futures-sink-0.3.31
  (crate-source "futures-sink" "0.3.31"
                "1xyly6naq6aqm52d5rh236snm08kw8zadydwqz8bip70s6vzlxg5"))

(define rust-futures-task-0.3.31
  (crate-source "futures-task" "0.3.31"
                "124rv4n90f5xwfsm9qw6y99755y021cmi5dhzh253s920z77s3zr"))

(define rust-futures-util-0.3.31
  (crate-source "futures-util" "0.3.31"
                "10aa1ar8bgkgbr4wzxlidkqkcxf77gffyj8j7768h831pcaq784z"))

(define rust-fuzzy-matcher-0.3.7
  (crate-source "fuzzy-matcher" "0.3.7"
                "153csv8rsk2vxagb68kpmiknvdd3bzqj03x805khckck28rllqal"))

(define rust-generic-array-0.14.5
  (crate-source "generic-array" "0.14.5"
                "00qqhls43bzvyb7s26iw6knvsz3mckbxl3rhaahvypzhqwzd6j7x"))

(define rust-getopts-0.2.21
  (crate-source "getopts" "0.2.21"
                "1mgb3qvivi26gs6ihqqhh8iyhp3vgxri6vwyrwg28w0xqzavznql"))

(define rust-getrandom-0.2.10
  (crate-source "getrandom" "0.2.10"
                "09zlimhhskzf7cmgcszix05wyz2i6fcpvh711cv1klsxl6r3chdy"))

(define rust-getrandom-0.3.1
  (crate-source "getrandom" "0.3.1"
                "1y154yzby383p63ndw6zpfm0fz3vf6c0zdwc7df6vkl150wrr923"))

(define rust-ghost-0.1.4
  (crate-source "ghost" "0.1.4"
                "0jpr9df3xq5zvi20nkfyq8m63iwjlcgcrhqsdzgx73rynvzi7j3n"))

(define rust-gimli-0.26.1
  (crate-source "gimli" "0.26.1"
                "1m0vi36ypv4gx9gzcw6y456yqnlypizhwlcqrmg6vkwd0lnkgk3q"))

(define rust-globset-0.4.10
  (crate-source "globset" "0.4.10"
                "1z4slzdx80qmv5l7pv2ac82jihwm4rrz9i50w6fybzfyk9c79782"))

(define rust-h2-0.4.10
  (crate-source "h2" "0.4.10"
                "19f0va87lhzrc0lmwkgcz1z0haf6glajb4icp0b7n50vdmkilhm9"))

(define rust-hashbrown-0.11.2
  (crate-source "hashbrown" "0.11.2"
                "0vkjsf5nzs7qcia5ya79j9sq2p1caz4crrncr1675wwyj3ag0pmb"))

(define rust-hashbrown-0.15.2
  (crate-source "hashbrown" "0.15.2"
                "12dj0yfn59p3kh3679ac0w1fagvzf4z2zp87a13gbbqbzw0185dz"))

(define rust-hashlink-0.8.4
  (crate-source "hashlink" "0.8.4"
                "1xy8agkyp0llbqk9fcffc1xblayrrywlyrm2a7v93x8zygm4y2g8"))

(define rust-heck-0.4.0
  (crate-source "heck" "0.4.0"
                "1ygphsnfwl2xpa211vbqkz1db6ri1kvkg8p8sqybi37wclg7fh15"))

(define rust-hermit-abi-0.3.1
  (crate-source "hermit-abi" "0.3.1"
                "11j2v3q58kmi5mhjvh6hfrb7il2yzg7gmdf5lpwnwwv6qj04im7y"))

(define rust-highway-0.6.4
  (crate-source "highway" "0.6.4"
                "0p9r4ss563gj44qamnrr5bqf0p9lb8gjc0w5jqmk3jlmyrlbjq9l"))

(define rust-http-0.2.9
  (crate-source "http" "0.2.9"
                "10j4jjpngaymxjvi92hllr2y6acr09pq61cvzxd44qzvkb4zyvmx"))

(define rust-http-1.3.1
  (crate-source "http" "1.3.1"
                "0r95i5h7dr1xadp1ac9453w0s62s27hzkam356nyx2d9mqqmva7l"))

(define rust-humantime-2.1.0
  (crate-source "humantime" "2.1.0"
                "1r55pfkkf5v0ji1x6izrjwdq9v6sc7bv99xj6srywcar37xmnfls"))

(define rust-hyper-1.6.0
  (crate-source "hyper" "1.6.0"
                "103ggny2k31z0iq2gzwk2vbx601wx6xkpjpxn40hr3p3b0b5fayc"))

(define rust-hyper-util-0.1.11
  (crate-source "hyper-util" "0.1.11"
                "1wj3svb1r6yv6kgk5fsz6wwajmngc4zxcw4wxpwlmpbgl8rvqys9"))

(define rust-iana-time-zone-0.1.60
  (crate-source "iana-time-zone" "0.1.60"
                "0hdid5xz3jznm04lysjm3vi93h3c523w0hcc3xba47jl3ddbpzz7"))

(define rust-icu-collections-2.1.1
  (crate-source "icu_collections" "2.1.1"
                "0hsblchsdl64q21qwrs4hvc2672jrf466zivbj1bwyv606bn8ssc"))

(define rust-icu-locale-core-2.1.1
  (crate-source "icu_locale_core" "2.1.1"
                "1djvdc2f5ylmp1ymzv4gcnmq1s4hqfim9nxlcm173lsd01hpifpd"))

(define rust-icu-normalizer-2.1.1
  (crate-source "icu_normalizer" "2.1.1"
                "16dmn5596la2qm0r3vih0bzjfi0vx9a20yqjha6r1y3vnql8hv2z"))

(define rust-icu-normalizer-data-2.1.1
  (crate-source "icu_normalizer_data" "2.1.1"
                "02jnzizg6q75m41l6c13xc7nkc5q8yr1b728dcgfhpzw076wrvbs"))

(define rust-icu-properties-2.1.2
  (crate-source "icu_properties" "2.1.2"
                "1v3lbmhhi7i6jgw51ikjb1p50qh5rb67grlkdnkc63l7zq1gq2q2"))

(define rust-icu-properties-data-2.1.2
  (crate-source "icu_properties_data" "2.1.2"
                "1bvpkh939rgzrjfdb7hz47v4wijngk0snmcgrnpwc9fpz162jv31"))

(define rust-icu-provider-2.1.1
  (crate-source "icu_provider" "2.1.1"
                "0576b7dizgyhpfa74kacv86y4g1p7v5ffd6c56kf1q82rvq2r5l5"))

(define rust-idna-adapter-1.2.1
  (crate-source "idna_adapter" "1.2.1"
                "0i0339pxig6mv786nkqcxnwqa87v4m94b2653f6k3aj0jmhfkjis"))

(define rust-ignore-0.4.20
  (crate-source "ignore" "0.4.20"
                "14kl9fv83klbnjxdv0y8lpwlj3gkypxf3vbrmm29m2jkmcyqgryv"))

(define rust-include-dir-0.7.3
  (crate-source "include_dir" "0.7.3"
                "17pinxhivh3chkbjmbg9sl0x3h7wwry2zc2p12gfh8kizyp2yxhq"))

(define rust-include-dir-macros-0.7.3
  (crate-source "include_dir_macros" "0.7.3"
                "0gsa6z58wxgw9j58w60wyjpk2nv3pd86kimw2akwyzpmbi5jhfdi"))

(define rust-indexmap-1.8.2
  (crate-source "indexmap" "1.8.2"
                "0nnaw0whv3xysrpjrz69bsibbscd81rwx63s6f4kbajv1ia2s0g6"))

(define rust-indexmap-2.7.1
  (crate-source "indexmap" "2.7.1"
                "0lmnm1zbr5gq3wic3d8a76gpvampridzwckfl97ckd5m08mrk74c"))

(define rust-inotify-0.9.6
  (crate-source "inotify" "0.9.6"
                "1zxb04c4qccp8wnr3v04l503qpxzxzzzph61amlqbsslq4z9s1pq"))

(define rust-insta-1.14.0
  (crate-source "insta" "1.14.0"
                "154f3ncpibbljkz4yvfqk5299asmdyybcpw01ijh2g64hzqn16b8"))

(define rust-instant-0.1.12
  (crate-source "instant" "0.1.12"
                "0b2bx5qdlwayriidhrag8vhy10kdfimfhmb3jnjmsz2h9j1bwnvs"))

(define rust-interprocess-2.3.1
  (crate-source "interprocess" "2.3.1"
                "0sn68jrkrnl04a9pmci97iim7imr9xy6vxljfd53kic50w72pgsk"))

(define rust-inventory-0.2.3
  (crate-source "inventory" "0.2.3"
                "06h9xw67wx18rank4yyz93iq89j0fk6fbazryfvf5ach1dp4qd44"))

(define rust-io-extras-0.18.4
  (crate-source "io-extras" "0.18.4"
                "0raay0wyzgmfdi0p9lphm19fmldwqgw9x47ynbs7w2al63zdv192"))

(define rust-io-lifetimes-1.0.10
  (crate-source "io-lifetimes" "1.0.10"
                "08625nsz0lgbd7c9lly6b6l45viqpsnj9jbsixd9mrz7596wfrlw"))

(define rust-io-lifetimes-2.0.3
  (crate-source "io-lifetimes" "2.0.3"
                "1373iwawish51r5dbd7fav1hp89idk30wkmbphyrg60y8xqi6qas"))

(define rust-ipnet-2.9.0
  (crate-source "ipnet" "2.9.0"
                "1hzrcysgwf0knf83ahb3535hrkw63mil88iqc6kjaryfblrqylcg"))

(define rust-is-ci-1.1.1
  (crate-source "is_ci" "1.1.1"
                "1ywra2z56x6d4pc02zq24a4x7gvpixynh9524icbpchbf9ydwv31"))

(define rust-is-terminal-0.4.7
  (crate-source "is-terminal" "0.4.7"
                "07xyfla3f2jjb666s72la5jvl9zq7mixbqkjvyfi5j018rhr7kxd"))

(define rust-isahc-1.7.2
  (crate-source "isahc" "1.7.2"
                "1scfgyv3dpjbkqa9im25cd12cs6rbd8ygcaw67f3dx41sys08kik"))

(define rust-itertools-0.10.5
  (crate-source "itertools" "0.10.5"
                "0ww45h7nxx5kj6z2y6chlskxd1igvs4j507anr6dzg99x1h25zdh"))

(define rust-itoa-1.0.14
  (crate-source "itoa" "1.0.14"
                "0x26kr9m062mafaxgcf2p6h2x7cmixm0zw95aipzn2hr3d5jlnnp"))

(define rust-jobserver-0.1.31
  (crate-source "jobserver" "0.1.31"
                "0vnyfxr5gm03j3lpnd1zswnyvqa40kbssy08pz2m35salfm9kc6j"))

(define rust-js-sys-0.3.64
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "js-sys" "0.3.64"
                "0nlkiwpm8dyqcf1xyc6qmrankcgdd3fpzc0qyfq2sw3z97z9bwf5"))

(define rust-kdl-4.5.0
  (crate-source "kdl" "4.5.0"
                "19kljlwdhfyidz0g1vgwrrjsrd25rmplfknrpccdwbhf3qvqlf58"))

(define rust-kqueue-1.0.7
  (crate-source "kqueue" "1.0.7"
                "165dvjbf7s0nv6q8r9zkzi1v0g81c65a81wqm9bi5xavl45wd3rc"))

(define rust-kqueue-sys-1.0.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "kqueue-sys" "1.0.3"
                "11z5labbms9vn9m6csi5383dmrlmdgsxq13ls9fwa6zhi5a5hrw3"))

(define rust-lazy-static-1.4.0
  (crate-source "lazy_static" "1.4.0"
                "0in6ikhw8mgl33wjv6q6xfrb5b9jr16q8ygjy803fay4zcisvaz2"))

(define rust-leb128-0.2.5
  (crate-source "leb128" "0.2.5"
                "0rxxjdn76sjbrb08s4bi7m4x47zg68f71jzgx8ww7j0cnivjckl8"))

(define rust-lev-distance-0.1.1
  (crate-source "lev_distance" "0.1.1"
                "0pk26fp1fcjyg2ml8g5ma1jj2gvgnmmri4md8y3bqdjr46yx3nbj"))

(define rust-libc-0.2.176
  (crate-source "libc" "0.2.176"
                "0x7ivn80h7nz2l46vra7bxx36s6r8d0lkax14dx97skjsss2kyaq"))

(define rust-libm-0.2.15
  (crate-source "libm" "0.2.15"
                "1plpzf0p829viazdj57yw5dhmlr8ywf3apayxc2f2bq5a6mvryzr"))

(define rust-libnghttp2-sys-0.1.8+1.55.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libnghttp2-sys" "0.1.8+1.55.1"
                "0h53v0jg0ihlqy6v7iz7rhrp70hbz9qxp5nfvaswvb9d35n9bbjg"))

(define rust-libredox-0.1.3
  (crate-source "libredox" "0.1.3"
                "139602gzgs0k91zb7dvgj1qh4ynb8g1lbxsswdim18hcb6ykgzy0"))

(define rust-libsqlite3-sys-0.27.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libsqlite3-sys" "0.27.0"
                "05pp60ncrmyjlxxjj187808jkvpxm06w5lvvdwwvxd2qrmnj4kng"))

(define rust-libssh2-sys-0.2.23
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libssh2-sys" "0.2.23"
                "1jplndqhlsygjmsni1ydb4zbw0j5jjr47bmqnjkwif5qnipa755h"))

(define rust-libz-sys-1.1.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libz-sys" "1.1.8"
                "1gqb8nk7j4ngvlcll8plm2fvjwic40p2g4qp20pwry1m74f7c0lp"))

(define rust-linked-hash-map-0.5.4
  (crate-source "linked-hash-map" "0.5.4"
                "1ww8zsraqnvrsknd315481185igwkx5n14xnhq5i8216z65b7fbz"))

(define rust-linux-raw-sys-0.3.7
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "linux-raw-sys" "0.3.7"
                "17s7qr5h82blrxy29014zzhr30jcxcjc8r16v2p31rzcfal7xsgc"))

(define rust-litemap-0.8.1
  (crate-source "litemap" "0.8.1"
                "0xsy8pfp9s802rsj1bq2ys2kbk1g36w5dr3gkfip7gphb5x60wv3"))

(define rust-lock-api-0.4.11
  (crate-source "lock_api" "0.4.11"
                "0iggx0h4jx63xm35861106af3jkxq06fpqhpkhgw0axi2n38y5iw"))

(define rust-log-0.4.17
  (crate-source "log" "0.4.17"
                "0biqlaaw1lsr8bpnmbcc0fvgjj34yy79ghqzyi0ali7vgil2xcdb"))

(define rust-log-mdc-0.1.0
  (crate-source "log-mdc" "0.1.0"
                "1iw1x3qhjvrac35spikn5h06a1rxd9vw216jk8h52jhz9i0j2kd9"))

(define rust-log4rs-1.2.0
  (crate-source "log4rs" "1.2.0"
                "1z9kfnba38smyrpmq49pjl82yqbvj2h81m3878cvhycydmwa2v6k"))

(define rust-matchit-0.8.4
  (crate-source "matchit" "0.8.4"
                "1hzl48fwq1cn5dvshfly6vzkzqhfihya65zpj7nz7lfx82mgzqa7"))

(define rust-maybe-owned-0.3.4
  (crate-source "maybe-owned" "0.3.4"
                "1d3sqiv59i06k73x6p7mf294zgdfb2qkky127ipfnjj9mr9wgb2g"))

(define rust-memchr-2.7.6
  (crate-source "memchr" "2.7.6"
                "0wy29kf6pb4fbhfksjbs05jy2f32r2f3r1ga6qkmpz31k79h0azm"))

(define rust-memoffset-0.6.5
  (crate-source "memoffset" "0.6.5"
                "1kkrzll58a3ayn5zdyy9i1f1v3mx0xgl29x0chq614zazba638ss"))

(define rust-miette-5.8.0
  (crate-source "miette" "5.8.0"
                "0mxkxawyqc6ybl3xp997kakwm89h5vw03rnqxylwlyam3n4r5acj"))

(define rust-miette-derive-5.8.0
  (crate-source "miette-derive" "5.8.0"
                "0ls1hdsnx6afpzhknzmai73axcg127jvx54kd7kcr6va30jwcrac"))

(define rust-mime-0.3.17
  (crate-source "mime" "0.3.17"
                "16hkibgvb9klh0w0jk5crr5xv90l3wlf77ggymzjmvl1818vnxv8"))

(define rust-miniz-oxide-0.5.3
  (crate-source "miniz_oxide" "0.5.3"
                "1k1wfxb35v129mhqy14yqhrj3wvknafrwygiq7zvi0m5iml7ap3g"))

(define rust-mio-0.8.11
  (crate-source "mio" "0.8.11"
                "034byyl0ardml5yliy1hmvx8arkmn9rv479pid794sm07ia519m4"))

(define rust-mio-1.0.3
  (crate-source "mio" "1.0.3"
                "1gah0h4ia3avxbwym0b6bi6lr6rpysmj9zvw6zis5yq0z0xq91i8"))

(define rust-multimap-0.8.3
  (crate-source "multimap" "0.8.3"
                "0sicyz4n500vdhgcxn4g8jz97cp1ijir1rnbgph3pmx9ckz4dkp5"))

(define rust-names-0.14.0
  (crate-source "names" "0.14.0"
                "1g1rxifcsvj9zj2nmwbdix8b5ynpghs4rq40vs966jqlylxwvpbv"))

(define rust-nix-0.23.1
  (crate-source "nix" "0.23.1"
                "1iimixk7y2qk0jswqich4mkd8kqyzdghcgy6203j8fmxmhbn71lz"))

(define rust-nom-7.1.1
  (crate-source "nom" "7.1.1"
                "0djc3lq5xihnwhrvkc4bj0fd58sjf632yh6hfiw545x355d3x458"))

(define rust-notify-6.1.1
  (crate-source "notify" "6.1.1"
                "0bad98r0ilkhhq2jg3zs11zcqasgbvxia8224wpasm74n65vs1b2"))

(define rust-notify-debouncer-full-0.3.2
  (crate-source "notify-debouncer-full" "0.3.2"
                "0kpkz1y4v2kwh5rgkhx4h2fxnwqka30lsrcy2vzwk2cpfdkd2zzv"))

(define rust-ntapi-0.4.2
  (crate-source "ntapi" "0.4.2"
                "10ghcc1kmj5ygy4ls81as6s5akd1wflwcc0b1k3nf8ql46g223y7"))

(define rust-num-traits-0.2.15
  (crate-source "num-traits" "0.2.15"
                "1kfdqqw2ndz0wx2j75v9nbjx7d3mh3150zs4p5595y02rwsdx3jp"))

(define rust-object-0.28.4
  (crate-source "object" "0.28.4"
                "0964501nlfh806mik3f9v6n05mx74qa0w7byvn0sqpwm5lprhb74"))

(define rust-once-cell-1.21.3
  (crate-source "once_cell" "1.21.3"
                "0b9x77lb9f1j6nqgf5aka4s2qj0nly176bpbrv6f9iakk5ff3xa2"))

(define rust-openssl-probe-0.1.5
  (crate-source "openssl-probe" "0.1.5"
                "1kq18qm48rvkwgcggfkqq6pm948190czqc94d6bm2sir5hq1l0gz"))

(define rust-openssl-src-300.5.4+3.5.4
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "openssl-src" "300.5.4+3.5.4"
                "0wnbqw38pzp66axaw2wz5my8nhg8f4viw74avyqfknlm55wv61x5"))

(define rust-openssl-sys-0.9.111
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "openssl-sys" "0.9.111"
                "08f3mpsabivfi3fd0qv9231qidqy68lr8a4qi32y6xda43av5jl2"))

(define rust-os-str-bytes-6.1.0
  (crate-source "os_str_bytes" "6.1.0"
                "1ykav0kv9152z4cmv8smwmd9pac9q42sihi4wphnrzlwx4c6hci1"))

(define rust-owo-colors-3.4.0
  (crate-source "owo-colors" "3.4.0"
                "0yx8glp9vipa6gybbqmpg8lyrcsrv9z6dia94p5lvshzja0p7kyy"))

(define rust-parking-2.0.0
  (crate-source "parking" "2.0.0"
                "0wnxxnizfxlax3n709s5r83f4n8awy3m4a18q4fdk0z7z693hz22"))

(define rust-parking-lot-0.11.2
  (crate-source "parking_lot" "0.11.2"
                "16gzf41bxmm10x82bla8d6wfppy9ym3fxsmdjyvn61m66s0bf5vx"))

(define rust-parking-lot-0.12.1
  (crate-source "parking_lot" "0.12.1"
                "13r2xk7mnxfc5g0g6dkdxqdqad99j7s7z8zhzz4npw5r0g0v4hip"))

(define rust-parking-lot-core-0.8.5
  (crate-source "parking_lot_core" "0.8.5"
                "05ij4zxsylx99srbq8qd1k2wiwaq8krkf9y4cqkhvb5wjca8wvnp"))

(define rust-parking-lot-core-0.9.9
  (crate-source "parking_lot_core" "0.9.9"
                "13h0imw1aq86wj28gxkblhkzx6z1gk8q18n0v76qmmj6cliajhjc"))

(define rust-pem-3.0.6
  (crate-source "pem" "3.0.6"
                "1glia9vv51wx79cysqxgdha6g1bwbbr20bfhijlk2nxw4qycac0x"))

(define rust-percent-encoding-2.3.1
  (crate-source "percent-encoding" "2.3.1"
                "0gi8wgx0dcy8rnv1kywdv98lwcx67hz0a0zwpib5v2i08r88y573"))

(define rust-pest-2.7.15
  (crate-source "pest" "2.7.15"
                "1p4rq45xprw9cx0pb8mmbfa0ih49l0baablv3cpfdy3c1pkayz4b"))

(define rust-petgraph-0.6.3
  (crate-source "petgraph" "0.6.3"
                "1912xw827flj8mzqm62jcbg0cv54qfhzm48c13ilzr9px67d5msd"))

(define rust-pin-project-1.1.3
  (crate-source "pin-project" "1.1.3"
                "08k4cpy8q3j93qqgnrbzkcgpn7g0a88l4a9nm33kyghpdhffv97x"))

(define rust-pin-project-internal-1.1.3
  (crate-source "pin-project-internal" "1.1.3"
                "01a4l3vb84brv9v7wl71chzxra2kynm6yvcjca66xv3ij6fgsna3"))

(define rust-pin-project-lite-0.2.14
  (crate-source "pin-project-lite" "0.2.14"
                "00nx3f04agwjlsmd3mc5rx5haibj2v8q9b52b0kwn63wcv4nz9mx"))

(define rust-pin-utils-0.1.0
  (crate-source "pin-utils" "0.1.0"
                "117ir7vslsl2z1a7qzhws4pd01cg2d3338c47swjyvqv2n60v1wb"))

(define rust-pkg-config-0.3.25
  (crate-source "pkg-config" "0.3.25"
                "1bh3vij79cshj884py4can1f8rvk52niaii1vwxya9q69gnc9y0x"))

(define rust-polling-2.2.0
  (crate-source "polling" "2.2.0"
                "0najvslgg2zclsnxay071jdw0bna7f0abqvgx3isv7w817ah8m38"))

(define rust-potential-utf-0.1.4
  (crate-source "potential_utf" "0.1.4"
                "0xxg0pkfpq299wvwln409z4fk80rbv55phh3f1jhjajy5x1ljfdp"))

(define rust-ppv-lite86-0.2.16
  (crate-source "ppv-lite86" "0.2.16"
                "0wkqwnvnfcgqlrahphl45vdlgi2f1bs7nqcsalsllp1y4dp9x7zb"))

(define rust-pretty-bytes-0.2.2
  (crate-source "pretty-bytes" "0.2.2"
                "05jkd1f824b93jh0jwfskba9hd70crvjz2nl1hf2xgqx5kfnx780"))

(define rust-proc-macro2-1.0.93
  (crate-source "proc-macro2" "1.0.93"
                "169dw9wch753if1mgyi2nfl1il77gslvh6y2q46qplprwml6m530"))

(define rust-prost-0.11.9
  (crate-source "prost" "0.11.9"
                "1kc1hva2h894hc0zf6r4r8fsxfpazf7xn5rj3jya9sbrsyhym0hb"))

(define rust-prost-build-0.11.9
  (crate-source "prost-build" "0.11.9"
                "0w5jx97q96ydhkg67wx3lb11kfy8195c56g0476glzws5iak758i"))

(define rust-prost-derive-0.11.9
  (crate-source "prost-derive" "0.11.9"
                "1d3mw2s2jba1f7wcjmjd6ha2a255p2rmynxhm1nysv9w1z8xilp5"))

(define rust-prost-types-0.11.9
  (crate-source "prost-types" "0.11.9"
                "04ryk38sqkp2nf4dgdqdfbgn6zwwvjraw6hqq6d9a6088shj4di1"))

(define rust-quote-1.0.36
  (crate-source "quote" "1.0.36"
                "19xcmh445bg6simirnnd4fvkmp6v2qiwxh5f6rw4a70h76pnm9qg"))

(define rust-rand-0.9.0
  (crate-source "rand" "0.9.0"
                "156dyvsfa6fjnv6nx5vzczay1scy5183dvjchd7bvs47xd5bjy9p"))

(define rust-rand-core-0.6.3
  (crate-source "rand_core" "0.6.3"
                "1rxlxc3bpzgwphcg9c9yasvv9idipcg2z2y4j0vlb52jyl418kyk"))

(define rust-rand-core-0.9.0
  (crate-source "rand_core" "0.9.0"
                "1zqmgsv276iy1jfxnndwpqjrgva39zck2f8i4ldpwbwn0ac3r3xh"))

(define rust-rcgen-0.13.2
  (crate-source "rcgen" "0.13.2"
                "18l0rz228pvnc44bjmvq8cchhh5d2rrkk98y9lqvan9243jnkrkm"))

(define rust-redox-syscall-0.2.13
  (crate-source "redox_syscall" "0.2.13"
                "0hpgwvgjlg1j9z7bjf5y18fkd8ag7y4znhqxg85hnpp5qz25pwk2"))

(define rust-redox-syscall-0.5.13
  (crate-source "redox_syscall" "0.5.13"
                "1mlzna9bcd7ss1973bmysr3hpjrys82b3bd7l03h4jkbxv8bf10d"))

(define rust-redox-users-0.4.3
  (crate-source "redox_users" "0.4.3"
                "0asw3s4iy69knafkhvlbchy230qawc297vddjdwjs5nglwvxhcxh"))

(define rust-regex-1.8.1
  (crate-source "regex" "1.8.1"
                "0w2kgdvs2fsv39hrsb912zjq3bx5vw1cchslvbi6mk1iycbyd0xg"))

(define rust-regex-syntax-0.7.1
  (crate-source "regex-syntax" "0.7.1"
                "0g1s6ra0ra8xy1fxscspd406c3pn53bjm1is8phamlwvy6a656d5"))

(define rust-rusqlite-0.30.0
  (crate-source "rusqlite" "0.30.0"
                "0kgjk7h53wp8k2di2j83ivf50f0bk6rg7bq8j36ygxb42lb4d057"))

(define rust-rustc-demangle-0.1.21
  (crate-source "rustc-demangle" "0.1.21"
                "0hn3xyd2n3bg3jnc5a5jbzll32n4r5a65bqzs287l30m5c53xw3y"))

(define rust-rustix-0.37.28
  (crate-source "rustix" "0.37.28"
                "1dn131z1vj1ani37acirby3rwh6ksm3m1qdv8k554xxrg39nb4ai"))

(define rust-rustix-1.1.2
  (crate-source "rustix" "1.1.2"
                "0gpz343xfzx16x82s1x336n0kr49j02cvhgxdvaq86jmqnigh5fd"))

(define rust-rustix-linux-procfs-0.1.1
  (crate-source "rustix-linux-procfs" "0.1.1"
                "0mi0w4zgw263gaf2ss5a2qg38hcqvh979wjqqzrc85max7vlpj1g"))

(define rust-rustls-0.23.27
  (crate-source "rustls" "0.23.27"
                "08d3nipyhmy4apksjyrb98s9k91wjyg1k7y0flx2671w135482bk"))

(define rust-rustls-pemfile-2.2.0
  (crate-source "rustls-pemfile" "2.2.0"
                "0l3f3mrfkgdjrava7ibwzgwc4h3dljw3pdkbsi9rkwz3zvji9qyw"))

(define rust-rustls-pki-types-1.12.0
  (crate-source "rustls-pki-types" "1.12.0"
                "0yawbdpix8jif6s8zj1p2hbyb7y3bj66fhx0y7hyf4qh4964m6i2"))

(define rust-rustls-webpki-0.103.13
  (crate-source "rustls-webpki" "0.103.13"
                "0vkm7z9pnxz5qz66p2kmyy2pwx0g4jnsbqk5xzfhs4czcjl2ki31"))

(define rust-rustversion-1.0.20
  (crate-source "rustversion" "1.0.20"
                "1lhwjb16dsm8brd18bn2bh0ryzc7qi29bi2jjsc6ny2zbwn3ivgd"))

(define rust-ryu-1.0.10
  (crate-source "ryu" "1.0.10"
                "15960rzj6jkjhxrjfr3kid2hbnia84s6h8l1ga7vkla9rwmgkxpk"))

(define rust-scc-2.3.4
  (crate-source "scc" "2.3.4"
                "1x1739jz8bx9x46d26aagwin9psykka1siw9fn0lbwi8zdsxgci2"))

(define rust-schannel-0.1.22
  (crate-source "schannel" "0.1.22"
                "126zy5jb95fc5hvzyjwiq6lc81r08rdcn6affn00ispp9jzk6dqc"))

(define rust-scopeguard-1.1.0
  (crate-source "scopeguard" "1.1.0"
                "1kbqm85v43rq92vx7hfiay6pmcga03vrjbbfwqpyj3pwsg3b16nj"))

(define rust-sdd-3.0.8
  (crate-source "sdd" "3.0.8"
                "08gfrs3cz2ncbqz7v1xm5687hggl166pic1frfk7s0f7244hfkjq"))

(define rust-semver-0.11.0
  (crate-source "semver" "0.11.0"
                "1dn6064fipjymnmjccyjhb70miyvqvp08gvw1wbg8vbg4c8ay0gk"))

(define rust-semver-parser-0.10.2
  (crate-source "semver-parser" "0.10.2"
                "1xqijhqhx3bn77xnl1mlcp032hz8nv7n2fbdacbdzq7rnzsvxc00"))

(define rust-serde-json-1.0.140
  (crate-source "serde_json" "1.0.140"
                "0wwkp4vc20r87081ihj3vpyz5qf7wqkqipq17v99nv6wjrp8n1i0"))

(define rust-serde-path-to-error-0.1.17
  (crate-source "serde_path_to_error" "0.1.17"
                "0alb447z25dvczd6ll3vfjbf51pypn23mgs5hv8978vzjczv3yjr"))

(define rust-serde-spanned-1.0.4
  (crate-source "serde_spanned" "1.0.4"
                "0xkp0qdzams5sqwndbw3xrhf4c0bb5r46w2ywkp1aqsdb8ggkfzq"))

(define rust-serde-yaml-0.8.24
  (crate-source "serde_yaml" "0.8.24"
                "1g5f4hlk2wlvwm3hdisd5r99iic8if1pqwrb6cl6dnqmaj4iazbh"))

(define rust-serial-test-3.2.0
  (crate-source "serial_test" "3.2.0"
                "1a8zg87gi28952hzj363ykwd8p1ssrakl1gi3f4xdqa4y84q298v"))

(define rust-serial-test-derive-3.2.0
  (crate-source "serial_test_derive" "3.2.0"
                "1vwyz2k5kiy5jmba0fvp6ph8ia707801bz918n2ff7bm11d2csax"))

(define rust-sha2-0.10.8
  (crate-source "sha2" "0.10.8"
                "1j1x78zk9il95w9iv46dh9wm73r6xrgj32y6lzzw7bxws9dbfgbr"))

(define rust-shell-words-1.1.0
  (crate-source "shell-words" "1.1.0"
                "1plgwx8r0h5ismbbp6cp03740wmzgzhip85k5hxqrrkaddkql614"))

(define rust-shellexpand-3.0.0
  (crate-source "shellexpand" "3.0.0"
                "1qc0d1zsaha7hphmyp0323zbndby5c6hrz9r9i44sab5lvg7s76x"))

(define rust-signal-hook-registry-1.4.0
  (crate-source "signal-hook-registry" "1.4.0"
                "1c2mhijg54y6c1zi4630yki1vpq3z96ljfnsrdy0rb64ilr767p5"))

(define rust-similar-2.1.0
  (crate-source "similar" "2.1.0"
                "1lw33na01r35h09s47jqhjgz3m29wapl20f6ybsla5d1cfgrf91f"))

(define rust-sixel-image-0.2.1
  (crate-source "sixel-image" "0.2.1"
                "17q4f21v4iixqngb06rc1nf5fhpin23ipdi61f8d5lsi3h2x8l83"))

(define rust-sixel-tokenizer-0.1.0
  (crate-source "sixel-tokenizer" "0.1.0"
                "0xnlg3vfmh96bqj1fnj6qdgjdnl0zc6v07ww2xh4v5mc55k7y6xp"))

(define rust-slab-0.4.6
  (crate-source "slab" "0.4.6"
                "0cmvcy9ppsh3dz8mi6jljx7bxyknvgpas4aid2ayxk1vjpz3qw7b"))

(define rust-sluice-0.5.5
  (crate-source "sluice" "0.5.5"
                "1d9ywr5039ibgaby8sc72f8fs5lpp8j5y6p3npya4jplxz000x3d"))

(define rust-smallvec-1.13.2
  (crate-source "smallvec" "1.13.2"
                "0rsw5samawl3wsw6glrsb127rx6sh89a8wyikicw6dkdcjd1lpiw"))

(define rust-smawk-0.3.1
  (crate-source "smawk" "0.3.1"
                "0hv0q1mw1r1brk7v3g4a80j162p7g1dri4bdidykrakzfqjd4ypn"))

(define rust-socket2-0.4.9
  (crate-source "socket2" "0.4.9"
                "0qnn1r41jqj20m0a2nzzjgzndlmpg5maiyjchccaypfqxq8sk934"))

(define rust-socket2-0.5.7
  (crate-source "socket2" "0.5.7"
                "070r941wbq76xpy039an4pyiy3rfj7mp7pvibf1rcri9njq5wc6f"))

(define rust-spin-0.9.8
  (crate-source "spin" "0.9.8"
                "0rvam5r0p3a6qhc18scqpvpgb3ckzyqxpgdfyjnghh8ja7byi039"))

(define rust-ssh2-0.9.3
  (crate-source "ssh2" "0.9.3"
                "1cgfwarj5k8s9fbf1pcnp27ifk30xk2f7q3sjca7l1ih8kk474r6"))

(define rust-string-interner-0.19.0
  (crate-source "string-interner" "0.19.0"
                "1h6jy7q32gjipylgwfiwsqr54dfrapx1cy56kff3875kg220ipi3"))

(define rust-strip-ansi-escapes-0.1.1
  (crate-source "strip-ansi-escapes" "0.1.1"
                "1n36ly9vxb1wr5q76i7995xr7c0pb1pc8g7a3a3n47vwrwwvn701"))

(define rust-strip-ansi-escapes-0.2.1
  (crate-source "strip-ansi-escapes" "0.2.1"
                "0980min1s9f5g47rwlq8l9njks952a0jlz0v7yxrm5p7www813ra"))

(define rust-suggest-0.4.0
  (crate-source "suggest" "0.4.0"
                "0nb6axl4i58g7k0q3p3bg6m363aw6qnqdg31y5c8b43x6bbd0n15"))

(define rust-supports-color-2.0.0
  (crate-source "supports-color" "2.0.0"
                "0m5kayz225f23k5jyjin82sfkrqhfdq3j72ianafkazz9cbyfl29"))

(define rust-supports-unicode-2.0.0
  (crate-source "supports-unicode" "2.0.0"
                "1xxscsdjmdp7i3ikqnnivfn4hnpy4gp9as4hshgd4pdb82r2qv2b"))

(define rust-syn-1.0.96
  (crate-source "syn" "1.0.96"
                "1gqymymz4202nfj76dkhr177wmcidch580vzf6w3qi943qjxsj07"))

(define rust-syn-2.0.96
  (crate-source "syn" "2.0.96"
                "102wk3cgawimi3i0q3r3xw3i858zkyingg6y7gsxfy733amsvl6m"))

(define rust-sysinfo-0.33.1
  (crate-source "sysinfo" "0.33.1"
                "00bcbj9rk39n07ylclj9klggkshxyianv2lfkpqnc6x0iqj5ij2g"))

(define rust-system-interface-0.27.2
  (crate-source "system-interface" "0.27.2"
                "19hh608hj3f3c0lc1vmd2dzkgmgbmhm3qbngnflqh03m49nm4n5q"))

(define rust-tempfile-3.10.1
  (crate-source "tempfile" "3.10.1"
                "1wdzz35ri168jn9al4s1g2rnsrr5ci91khgarc2rvpb3nappzdw5"))

(define rust-textwrap-0.15.0
  (crate-source "textwrap" "0.15.0"
                "1yw513k61lfiwgqrfvsjw1a5wpvm0azhpjr2kr0jhnq9c56is55i"))

(define rust-thiserror-1.0.61
  (crate-source "thiserror" "1.0.61"
                "028prh962l16cmjivwb1g9xalbpqip0305zhq006mg74dc6whin5"))

(define rust-thiserror-2.0.12
  (crate-source "thiserror" "2.0.12"
                "024791nsc0np63g2pq30cjf9acj38z3jwx9apvvi8qsqmqnqlysn"))

(define rust-thiserror-impl-1.0.61
  (crate-source "thiserror-impl" "1.0.61"
                "0cvm37hp0kbcyk1xac1z0chpbd9pbn2g456iyid6sah0a113ihs6"))

(define rust-thiserror-impl-2.0.12
  (crate-source "thiserror-impl" "2.0.12"
                "07bsn7shydaidvyyrm7jz29vp78vrxr9cr9044rfmn078lmz8z3z"))

(define rust-thread-id-4.0.0
  (crate-source "thread-id" "4.0.0"
                "0zvikdngp0950hi0jgiipr8l36rskk1wk7pc8cd43xr3g5if1psz"))

(define rust-thread-local-1.1.7
  (crate-source "thread_local" "1.1.7"
                "0lp19jdgvp5m4l60cgxdnl00yw1hlqy8gcywg9bddwng9h36zp9z"))

(define rust-tinystr-0.8.2
  (crate-source "tinystr" "0.8.2"
                "0sa8z88axdsf088hgw5p4xcyi6g3w3sgbb6qdp81bph9bk2fkls2"))

(define rust-tokio-1.44.2
  (crate-source "tokio" "1.44.2"
                "0j4w3qvlcqzgbxlnap0czvspqj6x461vyk1sbqcf97g4rci8if76"))

(define rust-tokio-macros-2.5.0
  (crate-source "tokio-macros" "2.5.0"
                "1f6az2xbvqp7am417b78d1za8axbvjvxnmkakz9vr8s52czx81kf"))

(define rust-tokio-rustls-0.26.2
  (crate-source "tokio-rustls" "0.26.2"
                "16wf007q3584j46wc4s0zc4szj6280g23hka6x6bgs50l4v7nwlf"))

(define rust-tokio-tungstenite-0.20.1
  (crate-source "tokio-tungstenite" "0.20.1"
                "0v1v24l27hxi5hlchs7hfd5rgzi167x0ygbw220nvq0w5b5msb91"))

(define rust-tokio-tungstenite-0.26.2
  (crate-source "tokio-tungstenite" "0.26.2"
                "117hwxfwmpxazxks076w5i73xj7cgv5iqs7x2rnbzln60zvaz7bs"))

(define rust-tokio-util-0.7.15
  (crate-source "tokio-util" "0.7.15"
                "1pypd9lm1fdnpw0779pqvc16qqrxjy63dgfm20ajhpbdmnlkk9b6"))

(define rust-toml-0.5.10
  (crate-source "toml" "0.5.10"
                "13srgxa0d92k8vdjyw8cyyax1pvi66smlyq1s7cs8s7891kwfcqk"))

(define rust-toml-0.9.6
  (crate-source "toml" "0.9.6"
                "00g2y1r2znl73s03qfb2sgc977hhqajxyp617gax28yshprlqamf"))

(define rust-toml-datetime-0.7.5+spec-1.1.0
  (crate-source "toml_datetime" "0.7.5+spec-1.1.0"
                "0iqkgvgsxmszpai53dbip7sf2igic39s4dby29dbqf1h9bnwzqcj"))

(define rust-toml-parser-1.0.9+spec-1.1.0
  (crate-source "toml_parser" "1.0.9+spec-1.1.0"
                "1i54qpvvcppy8ybdn9gssas81vfzq0kmgkcnxzhyf8w9w0al8bbh"))

(define rust-toml-writer-1.0.6+spec-1.1.0
  (crate-source "toml_writer" "1.0.6+spec-1.1.0"
                "01r6x42d1p8p5kzfsi1fm4dakm3w53vi69f2ivyqpvi1xm5g25mb"))

(define rust-tower-0.5.2
  (crate-source "tower" "0.5.2"
                "1ybmd59nm4abl9bsvy6rx31m4zvzp5rja2slzpn712y9b68ssffh"))

(define rust-tower-http-0.6.4
  (crate-source "tower-http" "0.6.4"
                "0bladfcd75dkh3ikmf2m4f971nc0zn8b5pb9mdbryym27hhhrnqg"))

(define rust-tracing-0.1.41
  (crate-source "tracing" "0.1.41"
                "1l5xrzyjfyayrwhvhldfnwdyligi1mpqm8mzbi2m1d6y6p2hlkkq"))

(define rust-tracing-attributes-0.1.28
  (crate-source "tracing-attributes" "0.1.28"
                "0v92l9cxs42rdm4m5hsa8z7ln1xsiw1zc2iil8c6k7lzq0jf2nir"))

(define rust-tracing-core-0.1.33
  (crate-source "tracing-core" "0.1.33"
                "170gc7cxyjx824r9kr17zc9gvzx89ypqfdzq259pr56gg5bwjwp6"))

(define rust-tracing-futures-0.2.5
  (crate-source "tracing-futures" "0.2.5"
                "1wimg0iwa2ldq7xv98lvivvf3q9ykfminig8r1bs0ig22np9bl4p"))

(define rust-tungstenite-0.20.1
  (crate-source "tungstenite" "0.20.1"
                "1fbgcv3h4h1bhhf5sqbwqsp7jnc44bi4m41sgmhzdsk2zl8aqgcy"))

(define rust-tungstenite-0.26.2
  (crate-source "tungstenite" "0.26.2"
                "04rwwcxx95m3avi46rmn0kmpb6nynqimnla3v2qwn3k8argcp4s7"))

(define rust-typenum-1.15.0
  (crate-source "typenum" "1.15.0"
                "11yrvz1vd43gqv738yw1v75rzngjbs7iwcgzjy3cq5ywkv2imy6w"))

(define rust-typetag-0.1.8
  (crate-source "typetag" "0.1.8"
                "12jva00k063gb48bvx0p0ixwbq1l48411disynzvah92bd65d020"))

(define rust-typetag-impl-0.1.8
  (crate-source "typetag-impl" "0.1.8"
                "03lw15ad39bgr4m6fmr5b9lb4wapkcfsnfxsbz0362635iw4f0g6"))

(define rust-unicode-ident-1.0.1
  (crate-source "unicode-ident" "1.0.1"
                "131niycgp77aiwvgjdyh47389xfnb7fmlc8ybrxys8v0a0kgxljv"))

(define rust-unicode-linebreak-0.1.2
  (crate-source "unicode-linebreak" "0.1.2"
                "0grq6bsn967q4vpifld53s7a140nlmpq5vy8ghgr73f4n2mdqlis"))

(define rust-unicode-width-0.1.10
  (crate-source "unicode-width" "0.1.10"
                "12vc3wv0qwg8rzcgb9bhaf5119dlmd6lmkhbfy1zfls6n7jx3vf0"))

(define rust-unicode-width-0.2.1
  (crate-source "unicode-width" "0.2.1"
                "0k0mlq7xy1y1kq6cgv1r2rs2knn6rln3g3af50rhi0dkgp60f6ja"))

(define rust-url-2.5.4
  (crate-source "url" "2.5.4"
                "0q6sgznyy2n4l5lm16zahkisvc9nip9aa5q1pps7656xra3bdy1j"))

(define rust-utf-8-0.7.6
  (crate-source "utf-8" "0.7.6"
                "1a9ns3fvgird0snjkd3wbdhwd3zdpc2h5gpyybrfr6ra5pkqxk09"))

(define rust-utf8parse-0.2.0
  (crate-source "utf8parse" "0.2.0"
                "0wjkvy22cxg023vkmvq2wwkgqyqam0d4pjld3m13blfg594lnvlk"))

(define rust-uuid-1.16.0
  (crate-source "uuid" "1.16.0"
                "1a9dkv6jm4lz7ip9l9i1mcx7sh389xjsr03l6jgwqjpmkdvpm3s5"))

(define rust-version-check-0.9.4
  (crate-source "version_check" "0.9.4"
                "0gs8grwdlgh0xq660d7wr80x14vxbizmd8dbp29p2pdncx8lp1s9"))

(define rust-vswhom-0.1.0
  (crate-source "vswhom" "0.1.0"
                "12v0fjjzxdc3y5c0lcwycfhphz7zf2s06hl5krwhawah0xzrp5xy"))

(define rust-vswhom-sys-0.1.3
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "vswhom-sys" "0.1.3"
                "0l0i4fijapsybmfckfqh53yqxsg0bm5ikja6vz8ngw0zpm67w1pv"))

(define rust-vte-0.10.1
  (crate-source "vte" "0.10.1"
                "10srmy9ssircrwsb5lpx3fbhx71460j77kvz0krz38jcmf9fdg3c"))

(define rust-vte-0.11.0
  (crate-source "vte" "0.11.0"
                "0iah6qvi8r6a1lslcwjg2g0jnczz72f3cvr3ihb2vv6j5b0j3bhs"))

(define rust-vte-0.14.1
  (crate-source "vte" "0.14.1"
                "0xy01fgkzb2080prh2ncd8949hm2248fc5wf1lryhdrhxzbxq7r3"))

(define rust-vte-generate-state-changes-0.1.1
  (crate-source "vte_generate_state_changes" "0.1.1"
                "1zs5q766q7jmc80c5c80gpzy4qpg5lnydf94mgdzrpy7h5q82myj"))

(define rust-waker-fn-1.1.0
  (crate-source "waker-fn" "1.1.0"
                "1jpfiis0frk2b36krqvk8264kgxk2dyhfzjsr8g3wah1nii2qnwx"))

(define rust-walkdir-2.3.3
  (crate-source "walkdir" "2.3.3"
                "16768hy32kcvghq7v4ci8llfjvdiwrwg6sj9nzcdiisnv9699prn"))

(define rust-wasi-0.11.0+wasi-snapshot-preview1
  (crate-source "wasi" "0.11.0+wasi-snapshot-preview1"
                "08z4hxwkpdpalxjps1ai9y7ihin26y9f476i53dv98v45gkqg3cw"))

(define rust-wasi-0.13.3+wasi-0.2.2
  (crate-source "wasi" "0.13.3+wasi-0.2.2"
                "1lnapbvdcvi3kc749wzqvwrpd483win2kicn1faa4dja38p6v096"))

(define rust-wasi-common-34.0.2
  (crate-source "wasi-common" "34.0.2"
                "075f056dxwbkzjizfg7hajiqc76jj01rr8swjqkngs2q1hc5lww2"))

(define rust-wasm-bindgen-0.2.87
  (crate-source "wasm-bindgen" "0.2.87"
                "0hm3k42gcnrps2jh339h186scx1radqy1w7v1zwb333dncmaf1kp"))

(define rust-wasm-bindgen-backend-0.2.87
  (crate-source "wasm-bindgen-backend" "0.2.87"
                "1gcsh3bjxhw3cirmin45107pcsnn0ymhkxg6bxg65s8hqp9vdwjy"))

(define rust-wasm-bindgen-macro-0.2.87
  (crate-source "wasm-bindgen-macro" "0.2.87"
                "07cg0b6zkcxa1yg1n10h62paid59s9zr8yss214bv8w2b7jrbr6y"))

(define rust-wasm-bindgen-macro-support-0.2.87
  (crate-source "wasm-bindgen-macro-support" "0.2.87"
                "0yqc46pr6mlgb9bsnfdnd50qvsqnrz8g5243fnaz0rb7lhc1ns2l"))

(define rust-wasm-bindgen-shared-0.2.87
  (crate-source "wasm-bindgen-shared" "0.2.87"
                "18bmjwvfyhvlq49nzw6mgiyx4ys350vps4cmx5gvzckh91dd0sna"))

(define rust-wasm-encoder-0.239.0
  (crate-source "wasm-encoder" "0.239.0"
                "0k0q5nxl91fphaa0fgh14aa3qnpaqg90ki0qwrpwfl295fm0zq2v"))

(define rust-wasmi-0.51.5
  (crate-source "wasmi" "0.51.5"
                "1zr381vdjj8r77w8nyr50am1i68x7phhiaapfs178hjrrq1i8cmv"))

(define rust-wasmi-collections-0.51.5
  (crate-source "wasmi_collections" "0.51.5"
                "0wlifks0r4aqh7jha9h7g0q9mjzirdjyf9c2kx4399d28n7fkf79"))

(define rust-wasmi-core-0.51.5
  (crate-source "wasmi_core" "0.51.5"
                "1rhjhmp1kwzxcx8aaiy715prdm0l3zv35x87mc78256z1if3fpy2"))

(define rust-wasmi-ir-0.51.5
  (crate-source "wasmi_ir" "0.51.5"
                "1nf36g5s5298acswwsxsxnrz775jjj1vcq22as7wngi9lil2lkk2"))

(define rust-wasmi-wasi-0.51.5
  (crate-source "wasmi_wasi" "0.51.5"
                "09b807fbawbz6xakmfmkk9cb1ksr0408jv00lqf0gp8dll6d2q1v"))

(define rust-wasmparser-0.228.0
  (crate-source "wasmparser" "0.228.0"
                "1qwa34ia97p8hn5rc3w76vrp0320a8hva6xwdgalgxzxq4r13gsa"))

(define rust-wasmparser-0.239.0
  (crate-source "wasmparser" "0.239.0"
                "1c386dryy1yx311aqqryb2k5c88aqwl21l7imfzgcr77jfxr17cc"))

(define rust-wast-239.0.0
  (crate-source "wast" "239.0.0"
                "0pgal4misdn1jx18xq6xqf9wn95jfgrwmkbln47hwnd2x1piffci"))

(define rust-wast-35.0.2
  (crate-source "wast" "35.0.2"
                "0s2d43g326dw21bygpalzjnr1fi83lx4afimg1h5hilrnkql1w9f"))

(define rust-wat-1.239.0
  (crate-source "wat" "1.239.0"
                "0x9vdz6bg0cj5r1m15jamgw0a80sj3w6d0amapr0jiyk4wcr871y"))

(define rust-wepoll-ffi-0.1.2
  (crate-source "wepoll-ffi" "0.1.2"
                "1yxpkva08d5f6ih3b5hdb8h45mkz3jq3dh1bzjspfhy6qpnzshyp"))

(define rust-which-4.2.5
  (crate-source "which" "4.2.5"
                "1bi4gklz7qcw19z4d2a4c1wsq083zc2387745rvsidhkc57baksw"))

(define rust-wiggle-34.0.2
  (crate-source "wiggle" "34.0.2"
                "009i3sxfji1r6xpn5b3k1m574b5djm28ywvlnzl364lqdb5kn7dn"))

(define rust-wiggle-generate-34.0.2
  (crate-source "wiggle-generate" "34.0.2"
                "1ynndq1c4zg8im46ljzgvvgm4c810bivcs5gq38jn3bx6lb9hzvf"))

(define rust-wiggle-macro-34.0.2
  (crate-source "wiggle-macro" "34.0.2"
                "1fdkijdi5az3dz14pdscr8rfdy3anw4vv239zdbxqy1ahsbma88y"))

(define rust-winapi-util-0.1.5
  (crate-source "winapi-util" "0.1.5"
                "0y71bp7f6d536czj40dhqk0d55wfbbwqfp2ymqf1an5ibgl6rv3h"))

(define rust-windows-0.57.0
  (crate-source "windows" "0.57.0"
                "0hqid10bqvxa3pbpgvrh2cilf950lxsd9zqfv3rldc73v2s2qd0j"))

(define rust-windows-aarch64-gnullvm-0.48.0
  (crate-source "windows_aarch64_gnullvm" "0.48.0"
                "1g71yxi61c410pwzq05ld7si4p9hyx6lf5fkw21sinvr3cp5gbli"))

(define rust-windows-aarch64-msvc-0.48.0
  (crate-source "windows_aarch64_msvc" "0.48.0"
                "1wvwipchhywcjaw73h998vzachf668fpqccbhrxzrz5xszh2gvxj"))

(define rust-windows-core-0.52.0
  (crate-source "windows-core" "0.52.0"
                "1nc3qv7sy24x0nlnb32f7alzpd6f72l4p24vl65vydbyil669ark"))

(define rust-windows-core-0.57.0
  (crate-source "windows-core" "0.57.0"
                "0bc3jxw2jw76xkk3ddvnp5b2m76qmbzv1qncgvb6qrlhl8wj9vfj"))

(define rust-windows-i686-gnu-0.48.0
  (crate-source "windows_i686_gnu" "0.48.0"
                "0hd2v9kp8fss0rzl83wzhw0s5z8q1b4875m6s1phv0yvlxi1jak2"))

(define rust-windows-i686-msvc-0.48.0
  (crate-source "windows_i686_msvc" "0.48.0"
                "004fkyqv3if178xx9ksqc4qqv8sz8n72mpczsr2vy8ffckiwchj5"))

(define rust-windows-implement-0.57.0
  (crate-source "windows-implement" "0.57.0"
                "1mqs7qypclnmx5r8yq5jy3g2d8i27vzag9yzzzxzpdnmb70ds1wi"))

(define rust-windows-interface-0.57.0
  (crate-source "windows-interface" "0.57.0"
                "19zwlzr0q1z9s692681yb5w2lhvwcyx4v95s25hfdkd3isry9gi9"))

(define rust-windows-targets-0.48.0
  (crate-source "windows-targets" "0.48.0"
                "1mfzg94w0c8h4ya9sva7rra77f3iy1712af9b6bwg03wrpqbc7kv"))

(define rust-windows-x86-64-gnu-0.48.0
  (crate-source "windows_x86_64_gnu" "0.48.0"
                "1cblz5m6a8q6ha09bz4lz233dnq5sw2hpra06k9cna3n3xk8laya"))

(define rust-windows-x86-64-gnullvm-0.48.0
  (crate-source "windows_x86_64_gnullvm" "0.48.0"
                "0lxryz3ysx0145bf3i38jkr7f9nxiym8p3syklp8f20yyk0xp5kq"))

(define rust-windows-x86-64-msvc-0.48.0
  (crate-source "windows_x86_64_msvc" "0.48.0"
                "12ipr1knzj2rwjygyllfi5mkd0ihnbi3r61gag5n2jgyk5bmyl8s"))

(define rust-winreg-0.55.0
  (crate-source "winreg" "0.55.0"
                "15xy060vylrsp91bc0ximx3xziwipzlrn1n2ab19w3n56x9pcnnb"))

(define rust-winx-0.36.3
  (crate-source "winx" "0.36.3"
                "0ikk6cnlfiq7dm36jqwrczxa8jyh9m2zmrdbxi3d430cha1knr7r"))

(define rust-wit-bindgen-rt-0.33.0
  (crate-source "wit-bindgen-rt" "0.33.0"
                "0g4lwfp9x6a2i1hgjn8k14nr4fsnpd5izxhc75zpi2s5cvcg6s1j"))

(define rust-witx-0.9.1
  (crate-source "witx" "0.9.1"
                "0jzgmayh2jjbv70jzfka38g4bk4g1fj9d0m70qkxpkdbbixg4rp3"))

(define rust-writeable-0.6.2
  (crate-source "writeable" "0.6.2"
                "1fg08y97n6vk7l0rnjggw3xyrii6dcqg54wqaxldrlk98zdy1pcy"))

(define rust-xflags-0.3.2
  (crate-source "xflags" "0.3.2"
                "0i490jzw7z9riqfnyginkc07j4k7isr19qq6055lamfyngxib7kx"))

(define rust-xflags-macros-0.3.2
  (crate-source "xflags-macros" "0.3.2"
                "0md1sh3h0yadrhjz2mh50xc65p0kx8qh19jvqbva5zx7zva26937"))

(define rust-xshell-0.2.2
  (crate-source "xshell" "0.2.2"
                "10d9xi5751p3bjpb8dfxxwxrplfn5m1b6l8qwjqk8ln8qmyhjivd"))

(define rust-xshell-macros-0.2.2
  (crate-source "xshell-macros" "0.2.2"
                "06n406clanafsg2zppk78xvggwynha7m6n6q8dfbznbdq9b1nc48"))

(define rust-yasna-0.5.2
  (crate-source "yasna" "0.5.2"
                "1ka4ixrplnrfqyl1kymdj8cwpdp2k0kdr73b57hilcn1kiab6yz1"))

(define rust-yoke-0.8.1
  (crate-source "yoke" "0.8.1"
                "0m29dm0bf5iakxgma0bj6dbmc3b8qi9b1vaw9sa76kdqmz3fbmkj"))

(define rust-yoke-derive-0.8.1
  (crate-source "yoke-derive" "0.8.1"
                "0pbyja133jnng4mrhimzdq4a0y26421g734ybgz8wsgbfhl0andn"))

(define rust-zerocopy-0.7.34
  (crate-source "zerocopy" "0.7.34"
                "11xhrwixm78m6ca1jdxf584wdwvpgg7q00vg21fhwl0psvyf71xf"))

(define rust-zerocopy-0.8.17
  (crate-source "zerocopy" "0.8.17"
                "04r7y63q0qanyk9ar9668sw8558mc0kvwfp0dp2nhfnfmiyl14da"))

(define rust-zerocopy-derive-0.7.34
  (crate-source "zerocopy-derive" "0.7.34"
                "0fqvglw01w3hp7xj9gdk1800x9j7v58s9w8ijiyiz2a7krb39s8m"))

(define rust-zerocopy-derive-0.8.17
  (crate-source "zerocopy-derive" "0.8.17"
                "09l698q12ni5470qajmxfhh9m5a6sfm37c8bzzax7jk5hcb8lw86"))

(define rust-zerofrom-0.1.6
  (crate-source "zerofrom" "0.1.6"
                "19dyky67zkjichsb7ykhv0aqws3q0jfvzww76l66c19y6gh45k2h"))

(define rust-zerofrom-derive-0.1.6
  (crate-source "zerofrom-derive" "0.1.6"
                "00l5niw7c1b0lf1vhvajpjmcnbdp2vn96jg4nmkhq2db0rp5s7np"))

(define rust-zeroize-1.8.1
  (crate-source "zeroize" "1.8.1"
                "1pjdrmjwmszpxfd7r860jx54cyk94qk59x13sc307cvr5256glyf"))

(define rust-zerotrie-0.2.3
  (crate-source "zerotrie" "0.2.3"
                "0lbqznlqazmrwwzslw0ci7p3pqxykrbfhq29npj0gmb2amxc2n9a"))

(define rust-zerovec-0.11.5
  (crate-source "zerovec" "0.11.5"
                "00m0p47k2g9mkv505hky5xh3r6ps7v8qc0dy4pspg542jj972a3c"))

(define rust-zerovec-derive-0.11.2
  (crate-source "zerovec-derive" "0.11.2"
                "1wsig4h5j7a1scd5hrlnragnazjny9qjc44hancb6p6a76ay7p7a"))


(define rust-accesskit-0.24.1
  (crate-source "accesskit" "0.24.1"
                "0863s1yvjk5f0a3ka46jhkaayaaqahi7dv80004nhpvybbwggdyk"))

(define rust-accesskit-atspi-common-0.19.1
  (crate-source "accesskit_atspi_common" "0.19.1"
                "0dnnazin69358bnyrnlq6bczifxrxw10na6mj9qdyikz17js0g82"))

(define rust-accesskit-consumer-0.38.0
  (crate-source "accesskit_consumer" "0.38.0"
                "0ic2z39avgqp2c26pkav3pq1whw5cw220ig4683xg1vgz4va442x"))

(define rust-accesskit-unix-0.22.1
  (crate-source "accesskit_unix" "0.22.1"
                "0brnj55m13xlw6si1qd7v01r723cpiqjdvwlx3pmxqq273nmdq83"))

(define rust-addr2line-0.25.1
  (crate-source "addr2line" "0.25.1"
                "0jwb96gv17vdr29hbzi0ha5q6jkpgjyn7rjlg5nis65k41rk0p8v"))

(define rust-aho-corasick-1.1.5
  (crate-source "aho-corasick" "1.1.5"
                "1fhjkp2nbs7gg4y1b68hpc8028rpax8aiscfh9b60q78m4pn90n9"))

(define rust-aligned-0.4.3
  (crate-source "aligned" "0.4.3"
                "1186lhb3gb4x6spzw7ff0zcraa8cr9zqk4ldpm5g1vb2ijc0higf"))

(define rust-aligned-vec-0.6.4
  (crate-source "aligned-vec" "0.6.4"
                "16vnf78hvfix5cwzd5xs5a2g6afmgb4h7n6yfsc36bv0r22072fw"))

(define rust-arbitrary-1.5.0
  (crate-source "arbitrary" "1.5.0"
                "1v8a080p8z746w8pi7lggaa5791qpk1i9mb313sj2cy3gk4jmiiv"))

(define rust-arg-enum-proc-macro-0.3.4
  (crate-source "arg_enum_proc_macro" "0.3.4"
                "1sjdfd5a8j6r99cf0bpqrd6b160x9vz97y5rysycsjda358jms8a"))

(define rust-as-slice-0.2.1
  (crate-source "as-slice" "0.2.1"
                "05j52y1ws8kir5zjxnl48ann0if79sb56p9nm76hvma01r7nnssi"))

(define rust-ashpd-0.13.13
  (crate-source "ashpd" "0.13.13"
                "04gilshi52djppigiy1y65iz05cvcs5japvk4spmyjk4m6m2317v"))

(define rust-async-fs-2.2.0
  (crate-source "async-fs" "2.2.0"
                "1iclw9970mh4ndb0bd68a6901kqy81rf9yypvf78pvaavy0scd40"))

(define rust-async-net-2.0.0
  (crate-source "async-net" "2.0.0"
                "1xyc5a5vcp3a7h1q2lbfh79wz8136dig4q4x6g4w2ws8ml7h0j5r"))

(define rust-atomic-0.5.3
  (crate-source "atomic" "0.5.3"
                "1fhc6ayg4d5vw1cibqwff15d45fc5448zg9i3drk42k5phsdp6y5"))

(define rust-atspi-0.29.0
  (crate-source "atspi" "0.29.0"
                "0ggvxv82n18kg497kfwrlzyfxw66c14fdrsakbc9q772gcjqcy67"))

(define rust-atspi-common-0.13.0
  (crate-source "atspi-common" "0.13.0"
                "0ggn55dgk2wz18spjx00gfkyfg747z8rlhhn6009h33lamqn3i90"))

(define rust-atspi-proxies-0.13.0
  (crate-source "atspi-proxies" "0.13.0"
                "1z690hglzw3rzv6xckxxgfvc086a69mbdslni44b8gpdhy3y8c12"))

(define rust-av-scenechange-0.14.1
  (crate-source "av-scenechange" "0.14.1"
                "1543y7riwcy4mmsgcalxcm3bnb41hvwiqiz774nbj68fq9vischg"))

(define rust-av1-grain-0.2.5
  (crate-source "av1-grain" "0.2.5"
                "1y3p43i5xncbny0pfh8kw09am3l3mgyg82ln65r3f434443xpzcc"))

(define rust-avif-serialize-0.8.9
  (crate-source "avif-serialize" "0.8.9"
                "0f3z55fma6xmdj0a0x15vz91cqisiardrfgbjlwb2q6lyzjqy5z7"))

(define rust-backtrace-0.3.76
  (crate-source "backtrace" "0.3.76"
                "1mibx75x4jf6wz7qjifynld3hpw3vq6sy3d3c9y5s88sg59ihlxv"))

(define rust-bit-field-0.10.3
  (crate-source "bit_field" "0.10.3"
                "1ikhbph4ap4w692c33r8bbv6yd2qxm1q3f64845grp1s6b3l0jqy"))

(define rust-bit-set-0.11.1
  (crate-source "bit-set" "0.11.1"
                "0739d91jr6k2rbmbcsh26sx6srd40rcl7wkv9yj597r2wia77n2n"))

(define rust-bit-set-0.9.1
  (crate-source "bit-set" "0.9.1"
                "1pd32sbz8kszw2ldbnaadwh1bhbpxs0jqm3rqyjvc6j2jllyzp9l"))

(define rust-bit-vec-0.10.1
  (crate-source "bit-vec" "0.10.1"
                "0s8jwc28d4fyi1ivh1wj69a9y9nh1raksz1v1bp4ykvxm5gv29sp"))

(define rust-bit-vec-0.9.1
  (crate-source "bit-vec" "0.9.1"
                "0l9zc1dkjmqykbfx1j14rnfy9rl1pjj5hwjs8j311zn1lby9h5xp"))

(define rust-bitstream-io-4.10.0
  (crate-source "bitstream-io" "4.10.0"
                "07zxcy47l51k6vsxphzhgcnqyzl21pprs7212687c64s56z01zvy"))

(define rust-block-padding-0.3.3
  (crate-source "block-padding" "0.3.3"
                "14wdad0r1qk5gmszxqd8cky6vx8qg7c153jv981mixzrpzmlz2d8"))

(define rust-borsh-1.8.1
  (crate-source "borsh" "1.8.1"
                "02p2lhz49944wc6j5dzr42y1mkrv0znbicg3cl61b9bbda25sg2m"))

(define rust-borsh-derive-1.8.1
  (crate-source "borsh-derive" "1.8.1"
                "0mlzrbwzcr7qaky1iap09m0nrzp6crjd79sinj4iz808cxjzxk8j"))

(define rust-built-0.8.1
  (crate-source "built" "0.8.1"
                "1saq332pd6g3svvc9ah8myjpfvgqlzl2ksb1ypp3976kjcfm63jw"))

(define rust-bytemuck-derive-1.12.1
  (crate-source "bytemuck_derive" "1.12.1"
                "17379imphax0d85jzkc50acw746mw89hjbrxqxlw1wmnhxjqj7va"))

(define rust-calloop-0.14.5
  (crate-source "calloop" "0.14.5"
                "0pjf9fmgq3zf3fnbcb3w9cml19lr0vv9pvhpklf75j1px49j7cs3"))

(define rust-cbc-0.1.2
  (crate-source "cbc" "0.1.2"
                "19l9y9ccv1ffg6876hshd123f2f8v7zbkc4nkckqycxf8fajmd96"))

(define rust-cc-1.8.0
  (crate-source "cc" "1.8.0"
                "0f6q6vc8fj6xn4j1wd4yakiza6lhgwai49gp1zdwgzggh3nwjlb6"))

(define rust-cfg-aliases-0.2.2
  (crate-source "cfg_aliases" "0.2.2"
                "09rm3dv28gbsal7w6q76lg2nfyn8wp789ska9b8vr1w750xfhygh"))

(define rust-cocoa-0.25.0
  (crate-source "cocoa" "0.25.0"
                "0g1pl5hq28arqmvsswf2ib7smj445miwa58qa7wrfvksz54h857n"))

(define rust-cocoa-foundation-0.1.2
  (crate-source "cocoa-foundation" "0.1.2"
                "1xwk1khdyqw3dwsl15vr8p86shdcn544fr60ass8biz4nb5k8qlc"))

(define rust-codespan-reporting-0.13.1
  (crate-source "codespan-reporting" "0.13.1"
                "10gnryisncjpfv7wi3jv9mhmrvqz6ksvfzddw3gf99q9k5b1sjdg"))

(define rust-color-quant-1.1.0
  (crate-source "color_quant" "1.1.0"
                "12q1n427h2bbmmm1mnglr57jaz2dj9apk0plcxw7nwqiai7qjyrx"))

(define rust-convert-case-0.11.0
  (crate-source "convert_case" "0.11.0"
                "0jfv1ajyr65bjlx533n5alfkfjdl8ks4zxfywdiz1jnj1qcz1yxg"))

(define rust-core-detect-1.0.0
  (crate-source "core_detect" "1.0.0"
                "0j0xp1j6f9lrp4ybylc3d0zdg8jq2hkmr1122qyil14qk84q13vz"))

(define rust-core-graphics-0.24.0
  (crate-source "core-graphics" "0.24.0"
                "1w8n8gqqm8swkanaibilqya8ryldp9fvf80byjxsaprn493a75gs"))

(define rust-core-graphics-helmer-fork-0.24.0
  (crate-source "core-graphics-helmer-fork" "0.24.0"
                "1mcwisxgzs287vbj76qhm0vr616dgv79k403lqvx9xp998sprsrj"))

(define rust-core-text-21.0.0
  (crate-source "core-text" "21.0.0"
                "0c61m5fb389br06n13cw808q6cfiw7czs38559xh1m6bcrxj54x5"))

(define rust-cosmic-text-0.19.0
  (crate-source "cosmic-text" "0.19.0"
                "0wys9shmdcibqacxl3qy50z5h48ff2xbx8j87zhlr4qda64bc5xy"))

(define rust-cpufeatures-0.3.1
  (crate-source "cpufeatures" "0.3.1"
                "0rkm1l35jy1z1yfg723fddsxc7vr0gc1hhfvc138hnqiwc58p8jw"))

(define rust-crossbeam-deque-0.8.8
  (crate-source "crossbeam-deque" "0.8.8"
                "06kip6ay8wcx5y4flg6wxbnyd44ay8308c8lf8y3iglh6v3kybv2"))

(define rust-crossbeam-queue-0.3.14
  (crate-source "crossbeam-queue" "0.3.14"
                "1bizbcv98anbink3gr3xhnb757d9vj6pcv7df2f4hybl5xvbvs03"))

(define rust-ctor-1.0.13
  (crate-source "ctor" "1.0.13"
                "03cqq01sx1jp07c26wdhm60ip6nvw8wigkppryyz4jidgidpajli"))

(define rust-data-url-0.3.2
  (crate-source "data-url" "0.3.2"
                "0xl30jidc8s3kh2z3nvnn1nyzhbq5b2wpiqwzj9gjdrndk50n7my"))

(define rust-deranged-0.5.9
  (crate-source "deranged" "0.5.9"
                "13nj445c8frp617vx84g1m5yp1gg63sg09gscbf907xdw8nfg7cy"))

(define rust-dirs-5.0.1
  (crate-source "dirs" "5.0.1"
                "0992xk5vx75b2x91nw9ssb51mpl8x73j9rxmpi96cryn0ffmmi24"))

(define rust-displaydoc-0.2.7
  (crate-source "displaydoc" "0.2.7"
                "1a42mwpgpwcqq2qqgkcc630wvsc2p2dkmgacjnclginwfz9js8y6"))

(define rust-dwrote-0.11.5
  (crate-source "dwrote" "0.11.5"
                "00jd7grrf7sz10y4zzipl0z8s27sbpirdl7fkjqwib1j4i9ka6wy"))

(define rust-either-1.19.0
  (crate-source "either" "1.19.0"
                "1gjq21g0sgk5ylpj85zafcinwhh3jj91i6drhb4278vw2v17370f"))

(define rust-embed-resource-3.0.12
  (crate-source "embed-resource" "3.0.12"
                "17r4794rvg84pwqq02yalqvf85l0hjqh04pydqz6gckybrxlhs31"))

(define rust-encoding-rs-0.8.42
  (crate-source "encoding_rs" "0.8.42"
                "0ycnbndly2jw5j69jl1r1lm512h2w9vb1dnjp0px46l7a425x64f"))

(define rust-enumn-0.1.14
  (crate-source "enumn" "0.1.14"
                "0f1gagm6841sih4ipw46c7gn1idjgqfay1f5q6hchdwjg2rxd7ig"))

(define rust-equator-0.4.2
  (crate-source "equator" "0.4.2"
                "1z760z5r0haxjyakbqxvswrz9mq7c29arrivgq8y1zldhc9v44a7"))

(define rust-equator-macro-0.4.2
  (crate-source "equator-macro" "0.4.2"
                "1cqzx3cqn9rxln3a607xr54wippzff56zs5chqdf3z2bnks3rwj4"))

(define rust-equivalent-1.0.3
  (crate-source "equivalent" "1.0.3"
                "09nqddaa84mix3vil6r02jlmya3qypi4j45dhzb8yphf83ap9l80"))

(define rust-etagere-0.2.15
  (crate-source "etagere" "0.2.15"
                "0hjkik00nl8bm9fafpzqkb6yah3mkphc21zpc159a5fwwncvz2gw"))

(define rust-exr-1.74.2
  (crate-source "exr" "1.74.2"
                "1wxd45pcgcc1zs7dcl39i2c4plp1w2gkzfizxq0mwab4k4nf87vi"))

(define rust-fax-0.2.7
  (crate-source "fax" "0.2.7"
                "0nmc65jjdym0f7lr4qm2q7awz1p5arm8i19wv1cmsg92cfahgwfa"))

(define rust-float-cmp-0.9.0
  (crate-source "float-cmp" "0.9.0"
                "1i799ksbq7fj9rm9m82g1yqgm6xi3jnrmylddmqknmksajylpplq"))

(define rust-float-next-after-1.0.0
  (crate-source "float_next_after" "1.0.0"
                "1s7ikn69b394frihag05b0qcw9i9y04qanlhp5c8sjrw70bcrxwb"))

(define rust-float-ord-0.3.2
  (crate-source "float-ord" "0.3.2"
                "0gbvx6dzz8xvj38bj02cajpqd9p5syxjx9jyqpj8414amr4izs4c"))

(define rust-font-types-0.11.3
  (crate-source "font-types" "0.11.3"
                "1mygnhm4xrnm803w2ax63ka3nm0s56l4h26mrs9xkbbdby8ssf2v"))

(define rust-font-types-0.12.7
  (crate-source "font-types" "0.12.7"
                "0pgks8skqzhjidjpxkyp154rl335pjf7yf6ydh17jjj6h7byjnl3"))

(define rust-fontconfig-parser-0.5.8
  (crate-source "fontconfig-parser" "0.5.8"
                "0ijnbzg31sl6v49g7q2l7sl76hjj8z0hvlsz77cdvm029vi77ixv"))

(define rust-fontdb-0.23.0
  (crate-source "fontdb" "0.23.0"
                "0199vry9x8zn9ix4x4rqvv53dy2ryhy68l53jwr580hj7ndphzj5"))

(define rust-fontdb-0.24.0
  (crate-source "fontdb" "0.24.0"
                "03r9lf9863cd128vb8qr11hyy156xfgllki9n4nnvxvv2plwaq16"))

(define rust-freetype-sys-0.20.1
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "freetype-sys" "0.20.1"
                "0d5iiv95ap3lwy7b0hxbc8caa9ng1fg3wlwrvb7rld39jrdxqzhf"))

(define rust-futures-0.3.34
  (crate-source "futures" "0.3.34"
                "18yhwmbdalhz2z9i1vm10hy2v0cfm82dkgcb6vr2msxazfix4ccs"))

(define rust-futures-channel-0.3.34
  (crate-source "futures-channel" "0.3.34"
                "1i4kwcanpaphn1ax62ci3nx176kglxqx0gnhzqpqdr1rkpbf7ydi"))

(define rust-futures-concurrency-7.7.1
  (crate-source "futures-concurrency" "7.7.1"
                "19lfx85mc4p15pj86bsyzv2f7690iw47bylgy63mpm71m76dhp0p"))

(define rust-futures-executor-0.3.34
  (crate-source "futures-executor" "0.3.34"
                "0cjl3y7jgg60wwb96ikxj23r6q91ylvx8v675yychv1w3b7lf6q3"))

(define rust-futures-macro-0.3.34
  (crate-source "futures-macro" "0.3.34"
                "0i0czvcvsqq4hrccibq2f23004si5z34zjwdxfmqhlrmm15nbfcz"))

(define rust-futures-sink-0.3.34
  (crate-source "futures-sink" "0.3.34"
                "07cfvrgc3vxk6sw5g8a8dnrm1mzg6d5mwy08ywa1sgyhyxml4i0r"))

(define rust-gif-0.14.2
  (crate-source "gif" "0.14.2"
                "0n81js7vlb9bwrjb765sicza3k0vrihjddrgm2mvpbfr272gr37f"))

(define rust-gimli-0.32.3
  (crate-source "gimli" "0.32.3"
                "1iqk5xznimn5bfa8jy4h7pa1dv3c624hzgd2dkz8mpgkiswvjag6"))

(define rust-glow-0.17.0
  (crate-source "glow" "0.17.0"
                "1dddw6wh5lm4apn1w6ikgh92w00n33pgwy6gndmwqr1k90f8w0r9"))

(define rust-harfrust-0.12.0
  (crate-source "harfrust" "0.12.0"
                "1ybn0c0yq6f1xw1749g45126hzwa95mdfz9g52xrn25a2jd98gf0"))

(define rust-harfrust-0.5.2
  (crate-source "harfrust" "0.5.2"
                "1ya5d0j39lf15vk27vncz616cbbadm6rggvp95k9cvhzhapfb8lx"))

(define rust-hkdf-0.12.4
  (crate-source "hkdf" "0.12.4"
                "1xxxzcarz151p1b858yn5skmhyrvn8fs4ivx5km3i1kjmnr8wpvv"))

(define rust-http-body-1.1.0
  (crate-source "http-body" "1.1.0"
                "0b5wj0rdj8p03k20q8x0jy249amg2db919fnmh7zcrgf2clqyana"))

(define rust-icu-collections-2.3.0
  (crate-source "icu_collections" "2.3.0"
                "04x59h6vdq0cnpippim1nr471ivlsnnn470sj1d5v864h48d4s7s"))

(define rust-icu-locale-core-2.3.0
  (crate-source "icu_locale_core" "2.3.0"
                "1sqdj16wwl7h9y6r7j394av4kpdb7zryz9h169ffwbm9imc2hvnm"))

(define rust-icu-normalizer-2.3.0
  (crate-source "icu_normalizer" "2.3.0"
                "0vv43ixk2wmbxrx7kl33cwkhx1wdyb1q3pa18qkyshan4dgwzy8j"))

(define rust-icu-normalizer-data-2.3.0
  (crate-source "icu_normalizer_data" "2.3.0"
                "1811h0ppb7lwq1q2492p5x6lcmlwmhbmkf69fhyvzcz0scgdlqqm"))

(define rust-icu-properties-2.3.0
  (crate-source "icu_properties" "2.3.0"
                "0j51hi8qgf0l6a7qzvnwsc61598w2fpnsklicld6ci9immva4z3y"))

(define rust-icu-properties-data-2.3.0
  (crate-source "icu_properties_data" "2.3.0"
                "1akw1gp5rcaiz377xzsnkx8f92qax4kh3lfn9y4rcjj6q4wg1475"))

(define rust-icu-provider-2.3.1
  (crate-source "icu_provider" "2.3.1"
                "0wrydhwprwgyka3r3sw6276syjnlw6fpqr2zsm2srvxv7afvnyyj"))

(define rust-imagesize-0.15.0
  (crate-source "imagesize" "0.15.0"
                "0ah45pw3bjwwca0nfq13z7yz6hikkbnkiicl7xzh6ay9q9h79ck5"))

(define rust-imgref-1.12.3
  (crate-source "imgref" "1.12.3"
                "0byjryn74gh3jxshkvmf81r7hnphspr67aah3m22zj54xajb0i3f"))

(define rust-interpolate-name-0.2.4
  (crate-source "interpolate_name" "0.2.4"
                "0q7s5mrfkx4p56dl8q9zq71y1ysdj4shh6f28qf9gly35l21jj63"))

(define rust-inventory-0.3.25
  (crate-source "inventory" "0.3.25"
                "0z6d57l6pkan8sdr4j87fwk1rfih1awir6hwpy8ss8n84ql2ha39"))

(define rust-jobserver-0.1.35
  (crate-source "jobserver" "0.1.35"
                "1crwgbb0wjph42ni4hqryjxlv4vlr0hyk81g76id9fpa56ysq00w"))

(define rust-kurbo-0.13.1
  (crate-source "kurbo" "0.13.1"
                "1qjhhjgwr9admlz6r1s7kp38dl8nbd95abhryrnr4av55z1xyq2b"))

(define rust-lebe-0.5.3
  (crate-source "lebe" "0.5.3"
                "1f459clndzzm35nyd15vj5dlasyagfasp7hcgl6lh2b658rs6ybs"))

(define rust-libc-0.2.191
  (crate-source "libc" "0.2.191"
                "02i4j7pjh129y92rijaia4576131fa2xjsii1dc3c1fnlv4qgkb5"))

(define rust-libfuzzer-sys-0.4.13
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "libfuzzer-sys" "0.4.13"
                "1li9z5q55wi81zzyifm7a4rw1xvcclsnqsqbkbvrk86bl50jzzd9"))

(define rust-libredox-0.1.25
  (crate-source "libredox" "0.1.25"
                "078pc91l1c1w9hbzi7m4ph5qjnk4i2zgsqhg4hx80yh7yv591zv1"))

(define rust-linebender-resource-handle-0.1.1
  (crate-source "linebender_resource_handle" "0.1.1"
                "1x34mrmqan0m3m9xf2iy6vpkcx6vwiiyzm2g3ixqdi56rimzz9fl"))

(define rust-link-section-0.19.3
  (crate-source "link-section" "0.19.3"
                "1nacjp2pfndy5xm1db28g6qy0xi3dsmw3gcphk035pz3gihrmhir"))

(define rust-linktime-proc-macro-0.2.3
  (crate-source "linktime-proc-macro" "0.2.3"
                "05ln47rqwf1gpa2hz9bnzmvnj8fj3pxwv0a2c1yd63w63s6c6mvy"))

(define rust-litemap-0.8.3
  (crate-source "litemap" "0.8.3"
                "1bpgpj87560hmckh3875fbahpmfxbk4g8pzns84h3ykf3nfx3na7"))

(define rust-litrs-1.0.1
  (crate-source "litrs" "1.0.1"
                "0w0d0gkx9ixccx9c00rq164ih9ak3jdq0jsivrpbh3czjn1y6i27"))

(define rust-loop9-0.1.5
  (crate-source "loop9" "0.1.5"
                "0qphc1c0cbbx43pwm6isnwzwbg6nsxjh7jah04n1sg5h4p0qgbhg"))

(define rust-lyon-1.0.19
  (crate-source "lyon" "1.0.19"
                "1dz70iwmcjij4f30gqgcs3wivy72lkiv3cmqhy4ximmpxjyph1dx"))

(define rust-lyon-algorithms-1.0.21
  (crate-source "lyon_algorithms" "1.0.21"
                "02b0yc8g0sf2l4yx1kz9g5g6zfmfjjcvbqrmvd6r2msyz62qgynd"))

(define rust-lyon-path-1.0.19
  (crate-source "lyon_path" "1.0.19"
                "07k2v24lxiwqdwzlhcqf3l8jj7m69b73kkaxi3ncazwb8af3yijw"))

(define rust-lyon-tessellation-1.0.22
  (crate-source "lyon_tessellation" "1.0.22"
                "01b0pqawwyf51jncymqjnfp7rwp7lk3l01rw3gvcwzk30vwxrf23"))

(define rust-mac-notification-sys-0.6.15
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "mac-notification-sys" "0.6.15"
                "1jmyr75x4py3wzr1w8rgxw36a55sjvxw14qiaqdw3p4djmrljq7x"))

(define rust-maybe-rayon-0.1.1
  (crate-source "maybe-rayon" "0.1.1"
                "06cmvhj4n36459g327ng5dnj8d58qs472pv5ahlhm7ynxl6g78cf"))

(define rust-memmap2-0.9.11
  (crate-source "memmap2" "0.9.11"
                "1h4qnzgarnn488ljjpg9ns5y4bw0sq0xv0fj0iqywagjnz8rw8fi"))

(define rust-multiversion-no-op-1.0.0
  (crate-source "multiversion_no_op" "1.0.0"
                "03d2k7xk7vky38q48h08miw4jca34ymckggnrqggn60vlddvagvl"))

(define rust-naga-29.0.4
  (crate-source "naga" "29.0.4"
                "1py81ph72a97ws2nwi70r12hsglrzgibm0fq4z5mm5z746b93gxj"))

(define rust-no-std-io2-0.9.4
  (crate-source "no_std_io2" "0.9.4"
                "00w0ggkaaacbwiv4qw188ih5llmhf53qgp20wk5gdyrldldvv2j1"))

(define rust-noop-proc-macro-0.3.0
  (crate-source "noop_proc_macro" "0.3.0"
                "1j2v1c6ric4w9v12h34jghzmngcwmn0hll1ywly4h6lcm4rbnxh6"))

(define rust-notify-rust-4.18.2
  (crate-source "notify-rust" "4.18.2"
                "1bzqpf3rprd0dkms6v2kdb2l0lr01aipbpxk54s36x00k953d1s5"))

(define rust-num-0.4.3
  (crate-source "num" "0.4.3"
                "08yb2fc1psig7pkzaplm495yp7c30m4pykpkwmi5bxrgid705g9m"))

(define rust-num-bigint-0.4.8
  (crate-source "num-bigint" "0.4.8"
                "0ry3xjal8f5xhdinani268ci13h14mf7j4w0y1gflfzhw3knk7n8"))

(define rust-num-bigint-dig-0.9.1
  (crate-source "num-bigint-dig" "0.9.1"
                "16g0xa96dc9nh2vxprw63rkm94lbyp16fmp6s1x1h3bv15paiyd7"))

(define rust-num-complex-0.4.6
  (crate-source "num-complex" "0.4.6"
                "15cla16mnw12xzf5g041nxbjjm9m85hdgadd5dl5d0b30w9qmy3k"))

(define rust-num-integer-0.1.47
  (crate-source "num-integer" "0.1.47"
                "02z1p3azy6p10n99skrab4a6hhfd4amf2i9gm8sxqd1p9dfxkqkw"))

(define rust-num-iter-0.1.46
  (crate-source "num-iter" "0.1.46"
                "12q4x0lp9l6bvsak1p5q24lvfzl99ak9vzmwhqbwksm1d6yh0a69"))

(define rust-objc-exception-0.1.2
  (crate-source "objc_exception" "0.1.2"
                "191cmdmlypp6piw67y4m8y5swlxf5w0ss8n1lk5xd2l1ans0z5xd"))

(define rust-objc-foundation-0.1.1
  (crate-source "objc-foundation" "0.1.1"
                "1y9bwb3m5fdq7w7i4bnds067dhm4qxv4m1mbg9y61j9nkrjipp8s"))

(define rust-objc-id-0.1.1
  (crate-source "objc_id" "0.1.1"
                "0fq71hnp2sdblaighjc82yrac3adfmqzhpr11irhvdfp9gdlsbf9"))

(define rust-object-0.37.3
  (crate-source "object" "0.37.3"
                "1zikiy9xhk6lfx1dn2gn2pxbnfpmlkn0byd7ib1n720x0cgj0xpz"))

(define rust-omi-1.0.0
  (crate-source "omi" "1.0.0"
                "05hd41fq8f2jvzika872s6f7xbh8689d760n55ds63s7im128iw3"))

(define rust-oo7-0.6.0
  (crate-source "oo7" "0.6.0"
                "1gffc8fn0lf3hwn68j999s4sw52yy83r7bfw915qnqgij3nvzwkq"))

(define rust-open-5.4.4
  (crate-source "open" "5.4.4"
                "1g7ffnbgl46s9nkwl8lxxwrpii1nfgk63066xj780yrb61v6qmxa"))

(define rust-ordered-float-5.5.0
  (crate-source "ordered-float" "5.5.0"
                "1h23hd8nf0nx9j2zg0iy130zwjqp4k3vl8070wk9yn13kc6rwz4c"))

(define rust-pastey-0.1.1
  (crate-source "pastey" "0.1.1"
                "1v389jkifv757903flrrps67dvc6q6giwlyx3xi33hcfjmgjxyrm"))

(define rust-pathfinder-geometry-0.5.1
  (crate-source "pathfinder_geometry" "0.5.1"
                "1lssir0s1cmrpzzrk49jm31nkssh2j715gryww6700x79rxpwyqb"))

(define rust-pathfinder-simd-0.5.6
  (crate-source "pathfinder_simd" "0.5.6"
                "0xsp8dh6pgrkm3anwdc4870bdv0sinaknvzk4gag2jif60606025"))

(define rust-pbkdf2-0.12.2
  (crate-source "pbkdf2" "0.12.2"
                "1wms79jh4flpy1zi8xdp4h8ccxv4d85adc6zjagknvppc5vnmvgq"))

(define rust-pico-args-0.5.0
  (crate-source "pico-args" "0.5.0"
                "05d30pvxd6zlnkg2i3ilr5a70v3f3z2in18m67z25vinmykngqav"))

(define rust-pin-project-1.1.13
  (crate-source "pin-project" "1.1.13"
                "09091qp946lpmjz4yp0xil1r5v4hgc91fi19dg5csayhdqrv4ri4"))

(define rust-pin-project-internal-1.1.13
  (crate-source "pin-project-internal" "1.1.13"
                "12rzlh07i1sdgrvzj6wgkka5bjqyvbfsl8knq6qi7g16m7q9aqy9"))

(define rust-pollster-0.2.5
  (crate-source "pollster" "0.2.5"
                "1xzji8cq4crr795c7liy3ksd798sb45pjphbm8h5gvnp7whb18sx"))

(define rust-pollster-0.4.0
  (crate-source "pollster" "0.4.0"
                "1qqcn0h2bvmgm9rlhfrdk7lfaiw1ad86g9500bhx1rj1s0c9yfig"))

(define rust-polycool-0.4.0
  (crate-source "polycool" "0.4.0"
                "19m52bzlr779l2ci8vpqp9qxyrlfaq4h5m5cbkvxanpb17f6snah"))

(define rust-portable-atomic-1.15.0
  (crate-source "portable-atomic" "1.15.0"
                "11csag858ndk5w4yz17h91vy53ynh67r2903gwwdn2cnilzbdj05"))

(define rust-portable-atomic-util-0.2.8
  (crate-source "portable-atomic-util" "0.2.8"
                "059729m166s1ccvqfyj6lv0wz5kr4qh6yb2gphf3mk5yyfvkxaqh"))

(define rust-postage-0.5.0
  (crate-source "postage" "0.5.0"
                "1hfk0rdwgv87aicna89ak0y3kz9ayakn28vwjdvgnx18cccbcgxg"))

(define rust-potential-utf-0.1.6
  (crate-source "potential_utf" "0.1.6"
                "0qbndl2fpphq7mph41m11vaixs05xrh1s451wxlgap4fdnybjgnq"))

(define rust-powerfmt-0.2.1
  (crate-source "powerfmt" "0.2.1"
                "0n293rvnpisjmxdqhq6zmrvcdql7j1c4zrcy5053vrv5x6wr8qsa"))

(define rust-profiling-procmacros-1.0.18
  (crate-source "profiling-procmacros" "1.0.18"
                "1jxvqff6j1z7ph3qghw2xhv18z7pf6cs6cja6fwscjwsdfis9224"))

(define rust-proptest-1.12.0
  (crate-source "proptest" "1.12.0"
                "186g52z5077c7q1xqm6v0kw43wqpwgxhj074qx8swpmirh200lxq"))

(define rust-proptest-macro-0.6.0
  (crate-source "proptest-macro" "0.6.0"
                "04n21cr7bwbwdmdyrfbcqa8v557ms8h14z48qq32533967m855z9"))

(define rust-pulp-0.22.3
  (crate-source "pulp" "0.22.3"
                "0sj9294yb8yr6z7vdlx467cfs4vvcwnygj0p8wpfqhlnk1ds8sh4"))

(define rust-pulp-wasm-simd-flag-0.1.1
  (crate-source "pulp-wasm-simd-flag" "0.1.1"
                "0h67yf9psibw4768lihrcidsdfqiqnhrrrblbaa64fcwggh713qx"))

(define rust-qoi-0.4.1
  (crate-source "qoi" "0.4.1"
                "00c0wkb112annn2wl72ixyd78mf56p4lxkhlmsggx65l3v3n8vbz"))

(define rust-rand-0.8.8
  (crate-source "rand" "0.8.8"
                "0k3d9psya5icpiylff1w1wjbnc3q4pb1953n1iw7gbr61ggcfn70"))

(define rust-rand-0.9.5
  (crate-source "rand" "0.9.5"
                "0hbvllk8g28mqjld6hqmckk69w296qpzg95whm3didsyg46ivvxr"))

(define rust-rand-xorshift-0.5.0
  (crate-source "rand_xorshift" "0.5.0"
                "1krcvzh8zb8ps8hy86lkj1wcr9zqcmp2xq0j60r72a731gw6mak0"))

(define rust-rangemap-1.8.0
  (crate-source "rangemap" "1.8.0"
                "0gdaws5kkg3md7z4w7ln4sf3jkz6n3f3xl5pfr6fngvla1dx24d6"))

(define rust-rav1e-0.8.1
  (crate-source "rav1e" "0.8.1"
                "0axk3ji3jmlr81svmsy5zvj8shmhpp8lz5nyghkq752xx1bdvdj3"))

(define rust-ravif-0.13.0
  (crate-source "ravif" "0.13.0"
                "0ifcpczxf6kcsqlky08vbjrvw9yd1m9mfszywxdhy6wpglci08z5"))

(define rust-raw-cpuid-11.6.0
  (crate-source "raw-cpuid" "11.6.0"
                "11j1lmrjqqnc43bxkrz0xai1g9piw3z9aap53qsj8cnpb7fd1329"))

(define rust-raw-window-metal-1.1.0
  (crate-source "raw-window-metal" "1.1.0"
                "0dg1ghsngiwhp0g42hls9h8zipblw0q76g112j9ca7azb92i7lj0"))

(define rust-read-fonts-0.37.0
  (crate-source "read-fonts" "0.37.0"
                "1r82vwrmsai9i7bgmnblb7sn08k2kca75lpz0x9v3yijy2mlyqvv"))

(define rust-read-fonts-0.41.0
  (crate-source "read-fonts" "0.41.0"
                "02c7q458gz6cfsyryiss5w6xp0k8dl2n4l1gncjrhidg9mkpssh4"))

(define rust-reborrow-0.5.5
  (crate-source "reborrow" "0.5.5"
                "0c14ccj3fdf47a1ya21bkxqv7s2hxrcfhaw98aqd6jqg029i2983"))

(define rust-regex-1.13.1
  (crate-source "regex" "1.13.1"
                "1391a0a4100ik8cp7l577p3ip3haqq03rd9c5vdr7vcfdixj687h"))

(define rust-regex-automata-0.4.18
  (crate-source "regex-automata" "0.4.18"
                "1cml0rm0ssqfkibh9nh3gy4b6hbsbicj1rihpwf2a4v4nawm71dd"))

(define rust-resvg-0.48.1
  (crate-source "resvg" "0.48.1"
                "1gcn2590qwl3hzs3qqz1j96j00l1gb8csvkwpw6fi6drjwzq1qv7"))

(define rust-roxmltree-0.20.0
  (crate-source "roxmltree" "0.20.0"
                "15vw91ps91wkmmgy62khf9zb63bdinvm80957dascbsw7dwvc83c"))

(define rust-roxmltree-0.21.1
  (crate-source "roxmltree" "0.21.1"
                "1fxc3jgvl2rk05bw0hj86azqg6mzlijh06gyi9pw69b1qw84p5pi"))

(define rust-rustc-demangle-0.1.28
  (crate-source "rustc-demangle" "0.1.28"
                "1sr083jamg89zcxmchia1pdn584smsy2r32kk9q30a5vm3zmcjxp"))

(define rust-rustc-hash-2.1.3
  (crate-source "rustc-hash" "2.1.3"
                "0bbla578m87qmf3yr55q49l97gxn7z0ha1dwqlnvwwc58ad7y7kb"))

(define rust-screencapturekit-0.2.8
  (crate-source "screencapturekit" "0.2.8"
                "0knn97lc4j304wdz8b4ssb4f8njqwqml0k7zwp7n0jf9gasywphs"))

(define rust-screencapturekit-sys-0.2.8
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "screencapturekit-sys" "0.2.8"
                "0q2cvqmwh4hci33ypx7gwlg5xmkgxq9qh695h3h7z7nlyxbinh92"))

(define rust-seahash-4.1.0
  (crate-source "seahash" "4.1.0"
                "0sxsb64np6bvnppjz5hg4rqpnkczhsl8w8kf2a5lr1c08xppn40w"))

(define rust-self-cell-1.3.0
  (crate-source "self_cell" "1.3.0"
                "04x883z7awzkmn5lqb67n51xynrj2pa9339jgq4j1qa94yh2rd1a"))

(define rust-serde-bytes-0.11.19
  (crate-source "serde_bytes" "0.11.19"
                "1a1y1v0r9akqyvprxnmpgc0i8wybqqpvgi01mi8qxn3rkrq41m55"))

(define rust-serde-spanned-1.1.2
  (crate-source "serde_spanned" "1.1.2"
                "0b0crd16vvp0n81pgh0ldi3apld0ph5ywsrml80y5v2ynnz26xaf"))

(define rust-sha1-smol-1.0.1
  (crate-source "sha1_smol" "1.0.1"
                "0pbh2xjfnzgblws3hims0ib5bphv7r5rfdpizyh51vnzvnribymv"))

(define rust-simd-helpers-0.1.0
  (crate-source "simd_helpers" "0.1.0"
                "19idqicn9k4vhd04ifh2ff41wvna79zphdf2c81rlmpc7f3hz2cm"))

(define rust-simplecss-0.2.2
  (crate-source "simplecss" "0.2.2"
                "0v0kid7b2602kcka2x2xs9wwfjf8lnvpgpl8x287qg4wra1ni73s"))

(define rust-skrifa-0.40.0
  (crate-source "skrifa" "0.40.0"
                "1b1lfid1326df2aq4cjqz7jv63m3i21czrgks7fxgyvm4hyzxgbz"))

(define rust-skrifa-0.44.0
  (crate-source "skrifa" "0.44.0"
                "0s5a3fnyrxfv514vjjrn268lyhihmh5nb9fyv7cp4ghx5gbbg6l1"))

(define rust-smallvec-1.16.3
  (crate-source "smallvec" "1.16.3"
                "06z0akmcq2zc9qg22dxda298p50gg3di5ggl3y2nllag8ypwhgav"))

(define rust-smol-2.0.2
  (crate-source "smol" "2.0.2"
                "17srgkyzswns43cnqcfb1846a8nsna47qj7wrk1rj8c9c3id6fx3"))

(define rust-smol-str-0.3.6
  (crate-source "smol_str" "0.3.6"
                "08qm7y1k2fkzrs8k78m03h4z4wbarv5g0bfr5m62m1glzil77aja"))

(define rust-spin-0.10.1
  (crate-source "spin" "0.10.1"
                "1lvxq2sdaissp7dzij94fsbrkxl9mmh2bcw0hr1vr38kncf22fh2"))

(define rust-spirv-0.4.0+sdk-1.4.341.0
  (crate-source "spirv" "0.4.0+sdk-1.4.341.0"
                "0kvlfqliwrrbdca9cpvwy43avimxkmzx4gjbmy34rn7b22liwmyr"))

(define rust-svg-fmt-0.4.5
  (crate-source "svg_fmt" "0.4.5"
                "1yq2kv7klg8s5k19prn36cprlnb811cqgwhy079g7lng651wr4q1"))

(define rust-svgtypes-0.16.1
  (crate-source "svgtypes" "0.16.1"
                "0gdw5a7znyv5sh4a575ddlhkvnvf45dd5grvkflsy78knf85fnv9"))

(define rust-swash-0.2.10
  (crate-source "swash" "0.2.10"
                "0bprhdib5yjpzvfb0nkqplwpm47di9qnh8ibhy416lr6v319j93c"))

(define rust-syn-3.0.9
  (crate-source "syn" "3.0.9"
                "0fw28lhl90kls24q2h2sp39yjb0lsvz5cwh9fd3f3w3v9kp8v36p"))

(define rust-synstructure-0.14.0
  (crate-source "synstructure" "0.14.0"
                "00kzyz38xqvs7x1dn6rp64y0ckly4m7ywf3qk3qkgqfzs3nh85wh"))

(define rust-sys-locale-0.3.2
  (crate-source "sys-locale" "0.3.2"
                "1i16hq9mkwpzqvixjfy1ph4i2q5klgagjg4hibz6k894l2crmawf"))

(define rust-sysinfo-0.31.4
  (crate-source "sysinfo" "0.31.4"
                "1gm1d4pxwnx4gmh6kwawchv8v8djb7y0a3qvbsq09cwrhx7vwp9m"))

(define rust-taffy-0.13.0
  (crate-source "taffy" "0.13.0"
                "03qxmgrg6m6sl1x98j86qxsm0wcpawjc4qrqlvd14np8drgy0d60"))

(define rust-tao-core-video-sys-0.2.0
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "tao-core-video-sys" "0.2.0"
                "1xlqdcp7a5hni0jwc7yn7p4mij68f86ffv0cfb8did4w53mm0517"))

(define rust-tauri-winrt-notification-0.8.1
  (crate-source "tauri-winrt-notification" "0.8.1"
                "0dnbghfcx348ryhqxmf952nnsmsr75zd96zd4biwk3yj9wsnqypk"))

(define rust-tiff-0.11.3
  (crate-source "tiff" "0.11.3"
                "0lmw68ic77sixk17r4rl2vsv00rqhja3yj2h9p5bcd9x6krylgxn"))

(define rust-time-0.3.55
  (crate-source "time" "0.3.55"
                "0d6iyws47z50zlksf5m3cflxvjrcgfhjglhn112gmpahxjappf6d"))

(define rust-time-core-0.1.9
  (crate-source "time-core" "0.1.9"
                "028ix0ax7ixp1h1k5zsqwgw85w6y1q32irslma7ci6ddd5kr074y"))

(define rust-tiny-skia-0.12.0
  (crate-source "tiny-skia" "0.12.0"
                "1sliba6ghl038ig7r4wds7aq9v5x1swmdqxh1xipylpmm9gfxzs7"))

(define rust-tiny-skia-path-0.12.0
  (crate-source "tiny-skia-path" "0.12.0"
                "1fgfzl0mzf2vfcqk3817wxynhmvcza05jg2r0rysdk5c7xf3djpd"))

(define rust-tinystr-0.8.4
  (crate-source "tinystr" "0.8.4"
                "0hzncw8rgk4syla79qscfml46jm7ll1zdp7kdacc42cj8n8prqmi"))

(define rust-tinyvec-1.13.3
  (crate-source "tinyvec" "1.13.3"
                "1vphg4gnlpykjy5h4v7r8nl38ij4zr9qyh7qd34ddvwjyqaa6g7x"))

(define rust-tokio-1.53.3
  (crate-source "tokio" "1.53.3"
                "0kny1nnbpy11dllv6ncxy3n804wh0ddn3msq78rxl744f7x3acyf"))

(define rust-toml-1.1.8+spec-1.1.0
  (crate-source "toml" "1.1.8+spec-1.1.0"
                "13b7kqvw7aa4x08i03d2fpima1i75v0lqxl0wrmisx6qwh09wj10"))

(define rust-toml-datetime-1.1.2+spec-1.1.0
  (crate-source "toml_datetime" "1.1.2+spec-1.1.0"
                "0lrhcmqvhjr259w4f2kijya7fgi0kpmhg9fb3m144v3cj1kxg1ib"))

(define rust-toml-edit-0.25.17+spec-1.1.0
  (crate-source "toml_edit" "0.25.17+spec-1.1.0"
                "174w1b2fjg1jb0wi7384v1m59g7ga79458i022gafjakpddisr73"))

(define rust-toml-parser-1.1.5+spec-1.1.0
  (crate-source "toml_parser" "1.1.5+spec-1.1.0"
                "0k3lljyi4zxchdklaqghkwbl7wkd2ab1w16hlyniqzid0fl979ms"))

(define rust-toml-writer-1.1.3+spec-1.1.0
  (crate-source "toml_writer" "1.1.3+spec-1.1.0"
                "0w17cps8mfg7wcwyp0gggi9cpgmxldb9pwl55qp8ssq5zj6bvg86"))

(define rust-unicode-ident-1.0.27
  (crate-source "unicode-ident" "1.0.27"
                "0qv54hz0sxmspjyr162z3435pnyylzjjhx3j4k1s359pqgb59ix2"))

(define rust-unicode-vo-0.1.0
  (crate-source "unicode-vo" "0.1.0"
                "151sha088v9jyfvbg5164xh4dk72g53b82xm4zzbf5dlagzqdlxi"))

(define rust-usvg-0.48.1
  (crate-source "usvg" "0.48.1"
                "149y95i3g0dwlcbg1ipb1awqkq3napwhkzlr9913z4zgpm50lzcp"))

(define rust-uuid-1.28.0
  (crate-source "uuid" "1.28.0"
                "01mnlhz09hwdjaxwzjd6bql3fjb5zl9n8dzaxn7dvdxyhiiiihbw"))

(define rust-v-frame-0.3.9
  (crate-source "v_frame" "0.3.9"
                "1qkvb4ks33zck931vzqckjn36hkngj6l2cwmvfsnlpc7r0kpfsv6"))

(define rust-waker-fn-1.2.0
  (crate-source "waker-fn" "1.2.0"
                "1dvk0qsv88kiq22x8w0qz0k9nyrxxm5a9a9czdwdvvhcvjh12wii"))

(define rust-wasm-bindgen-futures-0.4.79
  (crate-source "wasm-bindgen-futures" "0.4.79"
                "03k1wcg5j3wqk6vgy6gzcq868vsa9k81dlhqissfk0nrw96v7fiw"))

(define rust-web-sys-0.3.106
  ;; TODO REVIEW: Check bundled sources.
  (crate-source "web-sys" "0.3.106"
                "195bd1m14w3hsw5fg3sr938mh7y4cb260d0sq6a6brffxjfin9l8"))

(define rust-weezl-0.1.12
  (crate-source "weezl" "0.1.12"
                "122a1dhha6cib5az4ihcqlh60ns2bi6rskdv875p94lbvj6wk2m2"))

(define rust-wgpu-29.0.4
  (crate-source "wgpu" "29.0.4"
                "01sx6b31110cxc0h8k06zwkg8sm54xv19lhqpd61v2523c789s3n"))

(define rust-wgpu-core-29.0.4
  (crate-source "wgpu-core" "29.0.4"
                "1mx48dc3k1gnfaqs193gdwmp0pxpvibszi20k5d9cmjf4lr9hl9g"))

(define rust-wgpu-core-deps-apple-29.0.4
  (crate-source "wgpu-core-deps-apple" "29.0.4"
                "1ws70f53b4yj9p52ziwzcn1m7x4zyxn5863xws4pbq60qhk9xqzm"))

(define rust-wgpu-core-deps-emscripten-29.0.4
  (crate-source "wgpu-core-deps-emscripten" "29.0.4"
                "1bzhr47sh1c6l1km50i5mmfjgasmdv3b5xnmpnc994ywa7jrpq01"))

(define rust-wgpu-core-deps-wasm-29.0.4
  (crate-source "wgpu-core-deps-wasm" "29.0.4"
                "0n9hjjf37g35k31brs2hmwscpc4vsdr4y8jcgm4i5ag2idwv27xg"))

(define rust-wgpu-core-deps-windows-linux-android-29.0.4
  (crate-source "wgpu-core-deps-windows-linux-android" "29.0.4"
                "0mq24drvyv691rqdji25pcr7mvlcpmp6cvmf8xv09bgnpqdjqnaf"))

(define rust-wgpu-hal-29.0.4
  (crate-source "wgpu-hal" "29.0.4"
                "13a49nwmfj5mvydq7k4xz4dfhvgaaspkykkflhi1qc97fz0y3b4p"))

(define rust-wgpu-naga-bridge-29.0.4
  (crate-source "wgpu-naga-bridge" "29.0.4"
                "0qf1pgzp6k5fzahbvbb2npfak6jlzfj1dkc168i4nm27yl9n08lm"))

(define rust-wgpu-types-29.0.4
  (crate-source "wgpu-types" "29.0.4"
                "1xgqmpyl0zpffqp23b5fcq6gr6yz3a7qd8r3nbi4bjm8kk6q9gw4"))

(define rust-windows-capture-1.5.0
  (crate-source "windows-capture" "1.5.0"
                "091bi2fg3kgcy4l8vxzgxvarg31v6ak2r73y3bnbkpgyjlzgfk9s"))

(define rust-winreg-0.56.0
  (crate-source "winreg" "0.56.0"
                "046a5jpvc0yzr9c0wgik743k6yalr2f0bchy4c0nz7sazyh34vvx"))

(define rust-wio-0.2.2
  (crate-source "wio" "0.2.2"
                "199p404fp96w1f1c93bf1jrvaqwypxf3hmmldhww4jk4yhr9j4jx"))

(define rust-writeable-0.6.4
  (crate-source "writeable" "0.6.4"
                "1p3r4s4wbf3dksfpj3xyrn7id5p0f7r74mj6qx6ngjfd6cm2vn1s"))

(define rust-xcb-1.7.1
  (crate-source "xcb" "1.7.1"
                "0rh5nf63b68irmbavbakg6z4ncwji4mqdzlsx1p8a8p9w0asvhm6"))

(define rust-xcursor-0.3.11
  (crate-source "xcursor" "0.3.11"
                "08wfv0wrij9rrmbgfd2l8a132gyfax05abypllpmwic6hznk6fqn"))

(define rust-xim-ctext-0.3.0
  (crate-source "xim-ctext" "0.3.0"
                "0k186cy9dcw999w74ak39f1cfp2xhgpywbp8nqvkq3y4c9q1miia"))

(define rust-xim-parser-0.2.2
  (crate-source "xim-parser" "0.2.2"
                "1dyp9ma824i3vslklv8ad7mga96vgm7aiwqa31jmlbapi5gy9kjx"))

(define rust-xkbcommon-0.8.0
  (crate-source "xkbcommon" "0.8.0"
                "1j8s1sfwc6bw9phsca65rw3q3b5l2651v1s0pk5yxm6baa9wlrld"))

(define rust-xml-rs-0.8.29
  (crate-source "xml-rs" "0.8.29"
                "19y8s93sh2dx21bqlpagkixld2c66f3rln0j9k4k7zqxxnrgjl74"))

(define rust-xmlwriter-0.1.0
  (crate-source "xmlwriter" "0.1.0"
                "1fg0ldmkgiis6hnxpi1c9gy7v23y0lpi824bp8yp12fi3r82lypc"))

(define rust-y4m-0.8.0
  (crate-source "y4m" "0.8.0"
                "0j24y2zf60lpxwd7kyg737hqfyqx16y32s0fjyi6fax6w4hlnnks"))

(define rust-yazi-0.2.1
  (crate-source "yazi" "0.2.1"
                "1dgv0dd0329dcbs57z2wj03daz8y1axgprw3pf5yf5jsbcjkh5z0"))

(define rust-yoke-derive-0.8.4
  (crate-source "yoke-derive" "0.8.4"
                "0wbdvvdv9birwxrr9ynxj0k7as0f0ci7ihhck34yi09nvgibv3pc"))

(define rust-zbus-names-4.3.5
  (crate-source "zbus_names" "4.3.5"
                "1pc8w0m4g8k6f13c2by67fvnc06xib84gw58ivhmjymd9sz14al1"))

(define rust-zbus-xml-5.2.1
  (crate-source "zbus_xml" "5.2.1"
                "0ak849z0h42zrfvgmddsbim1abiq8vjp9n6w2s90mjh13816qn6i"))

(define rust-zed-font-kit-0.14.1-zed
  (crate-source "zed-font-kit" "0.14.1-zed"
                "1xdzz6a37y87n4ihnyai94n089j4qf2zkqvjvbnm5y1n1x2qx2d3"))

(define rust-zed-scap-0.0.8-zed
  (crate-source "zed-scap" "0.0.8-zed"
                "1j4ad4zqd360l5r1n43vll57lfih548w31q2l0ya8cxf0pbkicxn"))

(define rust-zed-xim-0.4.0-zed
  (crate-source "zed-xim" "0.4.0-zed"
                "0hl62iwc5pnm5px4r1ygl830wpk61gf4vnakpbck9flf27nlc2qc"))

(define rust-zeno-0.3.3
  (crate-source "zeno" "0.3.3"
                "0915lg3b1qiixizic9kwj2bw42x35baxqvl9dn0m2plkj91drwvd"))

(define rust-zerocopy-0.8.63
  (crate-source "zerocopy" "0.8.63"
                "1n1fm40mq4adw83hvn56j6rhnph0lldccx11jq01l6863f7izzp5"))

(define rust-zerocopy-derive-0.8.63
  (crate-source "zerocopy-derive" "0.8.63"
                "0zqc4g3yf378dkbsr68h1jjx3n0d4k4zvnxf83bv8gr9hfnd6fl6"))

(define rust-zerofrom-derive-0.1.8
  (crate-source "zerofrom-derive" "0.1.8"
                "0jhdy4p9c6ja3dynsdck14g2iilq8ai5ch6nsi455x67ys1lcnzp"))

(define rust-zeroize-1.9.1
  (crate-source "zeroize" "1.9.1"
                "0yb8iykihpl3hfw5c4silw2lklpfxajkaa9yj1qw6jsy5hwq8c71"))

(define rust-zeroize-derive-1.5.0
  (crate-source "zeroize_derive" "1.5.0"
                "0a7kq8srk81pn23xqn7c9jw1jpnfy41ffn802x1zrqqgpdf6al1w"))

(define rust-zerotrie-0.2.5
  (crate-source "zerotrie" "0.2.5"
                "0gss16krjzk22m57dz5hkdjg99ibj6pa41qr68na7w1jpp1nk8jf"))

(define rust-zerovec-0.11.8
  (crate-source "zerovec" "0.11.8"
                "1n3xlvyba8riys9s8awy4xp533phqycr78nbsmvdkh86g3hn815v"))

(define rust-zerovec-derive-0.11.6
  (crate-source "zerovec-derive" "0.11.6"
                "1ni5j8v99x3fcf3l8kp64b7aq4vf8y22jshfq74xs9mxkp1nzprl"))

(define rust-zune-core-0.5.3
  (crate-source "zune-core" "0.5.3"
                "12v5zdwcmjwzlfz61ajchzdaab75cxasqnmwf2hq929n8vypfqym"))

(define rust-zune-inflate-0.2.54
  (crate-source "zune-inflate" "0.2.54"
                "00kg24jh3zqa3i6rg6yksnb71bch9yi1casqydl00s7nw8pk7avk"))

(define rust-zune-jpeg-0.5.15
  (crate-source "zune-jpeg" "0.5.15"
                "15kjpn6pywxlwb8w5irfd68x31wi3mb4y1da8bqh7havh5drvg17"))

(define rust-zvariant-5.15.1
  (crate-source "zvariant" "5.15.1"
                "1dzvl7la92pc8qyaw9pgfpxgqhy6rn285yscnsn03dm4srn6vgw0"))

(define rust-zvariant-derive-5.15.1
  (crate-source "zvariant_derive" "5.15.1"
                "0va8dm4k7rk2iar573lkzfap8g2v2dinw4zcxasm9jx1dd2p49pg"))


(define rust-mockall-0.15.0
  (crate-source "mockall" "0.15.0"
                "12mgvvd7c9k2rs71cak3dknmpvnwnbyj1x3bx4jljcyfwggysv0s"))

(define rust-mockall-derive-0.15.0
  (crate-source "mockall_derive" "0.15.0"
                "1n3g84c6m7av8x2v1filfvlj7qdic17c46l61gnaw553x3xidzlw"))

(define rust-objc2-open-directory-0.3.2
  (crate-source "objc2-open-directory" "0.3.2"
                "0vb77yig142s54vrhlcq98ykv8qm82x2n1yzzqfj1xgd4z9bx0mv"))

(define rust-sysinfo-0.39.6
  (crate-source "sysinfo" "0.39.6"
                "1rk12gjbharifw5m80ag4fyi4by2y7m5vlp69wfbf5c98kwis1yj"))

(define rust-textwrap-0.16.4
  (crate-source "textwrap" "0.16.4"
                "0jfdxds0k50c3cy5a2s31l37lzp55r0iw75ry9vsb05w79navkvf"))

(define rust-thread-local-1.1.10
  (crate-source "thread_local" "1.1.10"
                "0w20g2pfdcp8pz3gds0bzksv6mxk802szca8qlr3701jdm69rn8s"))

(define rust-time-macros-0.2.32
  (crate-source "time-macros" "0.2.32"
                "11gdd3b81mj8i0h114qfjjzm8j2rz2mhr9byr0ksjbldli196s3y"))


(define ssss-separator 'end-of-crates)

;;;
;;; Cargo inputs.
;;;

(define-cargo-inputs lookup-cargo-inputs
                     (git-credential-keepassxc =>
                                               (list rust-aead-0.5.2
                                                rust-aes-0.7.5
                                                rust-aes-0.8.4
                                                rust-aes-gcm-0.10.3
                                                rust-android-system-properties-0.1.6
                                                rust-anstyle-1.0.14
                                                rust-anyhow-1.0.104
                                                rust-async-broadcast-0.7.2
                                                rust-async-channel-2.5.0
                                                rust-async-executor-1.14.0
                                                rust-async-io-2.6.0
                                                rust-async-lock-3.4.2
                                                rust-async-process-2.5.0
                                                rust-async-recursion-1.2.0
                                                rust-async-signal-0.2.14
                                                rust-async-task-4.7.1
                                                rust-async-trait-0.1.92
                                                rust-atomic-waker-1.1.2
                                                rust-atty-0.2.14
                                                rust-autocfg-1.5.1
                                                rust-base64-0.23.1
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.13.2
                                                rust-block-buffer-0.10.4
                                                rust-block-buffer-0.9.0
                                                rust-block-modes-0.8.1
                                                rust-block-padding-0.2.1
                                                rust-block2-0.6.2
                                                rust-blocking-1.7.0
                                                rust-bumpalo-3.20.3
                                                rust-byteorder-1.5.0
                                                rust-cc-1.8.0
                                                rust-cfg-aliases-0.2.2
                                                rust-cfg-if-1.0.5
                                                rust-chrono-0.4.45
                                                rust-cipher-0.3.0
                                                rust-cipher-0.4.4
                                                rust-clap-3.2.25
                                                rust-clap-derive-3.2.25
                                                rust-clap-lex-0.2.4
                                                rust-concurrent-queue-2.5.0
                                                rust-core-foundation-sys-0.8.7
                                                rust-cpufeatures-0.2.17
                                                rust-crossbeam-utils-0.8.23
                                                rust-crypto-box-0.9.1
                                                rust-crypto-common-0.1.7
                                                rust-crypto-mac-0.11.1
                                                rust-crypto-secretbox-0.1.1
                                                rust-ctr-0.9.2
                                                rust-curve25519-dalek-4.1.3
                                                rust-curve25519-dalek-derive-0.1.1
                                                rust-deranged-0.5.9
                                                rust-digest-0.10.7
                                                rust-digest-0.9.0
                                                rust-directories-next-2.0.0
                                                rust-dirs-sys-next-0.1.2
                                                rust-dispatch2-0.3.1
                                                rust-downcast-0.11.0
                                                rust-endi-1.1.1
                                                rust-enumflags2-0.7.12
                                                rust-enumflags2-derive-0.7.12
                                                rust-equivalent-1.0.3
                                                rust-erased-serde-0.3.31
                                                rust-errno-0.3.14
                                                rust-event-listener-5.4.2
                                                rust-event-listener-strategy-0.5.4
                                                rust-fastrand-2.5.0
                                                rust-fiat-crypto-0.2.9
                                                rust-find-msvc-tools-0.1.14
                                                rust-fragile-2.1.0
                                                rust-futures-core-0.3.34
                                                rust-futures-io-0.3.34
                                                rust-futures-lite-2.6.1
                                                rust-futures-task-0.3.34
                                                rust-futures-util-0.3.34
                                                rust-generic-array-0.14.7
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.4.3
                                                rust-ghash-0.5.1
                                                rust-hashbrown-0.12.3
                                                rust-hashbrown-0.17.1
                                                rust-heck-0.4.1
                                                rust-heck-0.5.0
                                                rust-hermit-abi-0.1.19
                                                rust-hermit-abi-0.5.3
                                                rust-hex-0.4.3
                                                rust-hmac-0.11.0
                                                rust-hmac-0.12.1
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-indexmap-1.9.3
                                                rust-indexmap-2.14.2
                                                rust-inout-0.1.4
                                                rust-is-terminal-0.4.17
                                                rust-itoa-1.0.18
                                                rust-js-sys-0.3.106
                                                rust-libc-0.2.190
                                                rust-libredox-0.1.25
                                                rust-libusb1-sys-0.5.0
                                                rust-linux-raw-sys-0.12.1
                                                rust-log-0.4.34
                                                rust-mac-notification-sys-0.6.15
                                                rust-memchr-2.8.3
                                                rust-memoffset-0.9.1
                                                rust-mockall-0.15.0
                                                rust-mockall-derive-0.15.0
                                                rust-named-pipe-0.4.1
                                                rust-nix-0.31.3
                                                rust-notify-rust-4.18.2
                                                rust-ntapi-0.4.3
                                                rust-num-conv-0.2.2
                                                rust-num-enum-0.7.6
                                                rust-num-enum-derive-0.7.6
                                                rust-num-traits-0.2.19
                                                rust-objc2-0.6.5
                                                rust-objc2-core-foundation-0.3.2
                                                rust-objc2-encode-4.1.0
                                                rust-objc2-foundation-0.3.2
                                                rust-objc2-io-kit-0.3.2
                                                rust-objc2-open-directory-0.3.2
                                                rust-once-cell-1.21.4
                                                rust-opaque-debug-0.3.1
                                                rust-ordered-stream-0.2.0
                                                rust-os-str-bytes-6.6.1
                                                rust-parking-2.2.1
                                                rust-pin-project-lite-0.2.17
                                                rust-piper-0.2.5
                                                rust-pkg-config-0.3.34
                                                rust-polling-3.11.0
                                                rust-poly1305-0.8.0
                                                rust-polyval-0.6.2
                                                rust-powerfmt-0.2.1
                                                rust-ppv-lite86-0.2.21
                                                rust-prctl-1.0.0
                                                rust-predicates-3.1.4
                                                rust-predicates-core-1.0.10
                                                rust-predicates-tree-1.0.13
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro-error-1.0.4
                                                rust-proc-macro-error-attr-1.0.4
                                                rust-proc-macro-hack-0.4.3
                                                rust-proc-macro-hack-impl-0.4.3
                                                rust-proc-macro2-1.0.107
                                                rust-quote-0.3.15
                                                rust-quote-1.0.47
                                                rust-r-efi-6.0.0
                                                rust-rand-0.8.8
                                                rust-rand-chacha-0.3.1
                                                rust-rand-core-0.6.4
                                                rust-redox-users-0.4.6
                                                rust-rusb-0.8.1
                                                rust-rustc-version-0.4.1
                                                rust-rustix-1.1.5
                                                rust-rustversion-1.0.23
                                                rust-salsa20-0.10.2
                                                rust-semver-1.0.28
                                                rust-serde-1.0.229
                                                rust-serde-core-1.0.229
                                                rust-serde-derive-1.0.229
                                                rust-serde-json-1.0.154
                                                rust-serde-repr-0.1.21
                                                rust-sha-1-0.10.1
                                                rust-sha-1-0.9.8
                                                rust-shlex-2.0.1
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
                                                rust-syn-2.0.119
                                                rust-syn-3.0.9
                                                rust-sysinfo-0.39.6
                                                rust-tabwriter-1.4.1
                                                rust-tauri-winrt-notification-0.8.1
                                                rust-tempfile-3.27.0
                                                rust-term-1.2.1
                                                rust-termcolor-1.4.1
                                                rust-termtree-0.5.1
                                                rust-textwrap-0.16.4
                                                rust-thiserror-1.0.69
                                                rust-thiserror-2.0.21
                                                rust-thiserror-impl-1.0.69
                                                rust-thiserror-impl-2.0.21
                                                rust-thread-local-1.1.10
                                                rust-time-0.3.55
                                                rust-time-core-0.1.9
                                                rust-time-macros-0.2.32
                                                rust-toml-datetime-1.1.2+spec-1.1.0
                                                rust-toml-edit-0.25.17+spec-1.1.0
                                                rust-toml-parser-1.1.5+spec-1.1.0
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-typenum-1.20.1
                                                rust-uds-windows-1.2.1
                                                rust-unicode-ident-1.0.27
                                                rust-unicode-width-0.2.2
                                                rust-universal-hash-0.5.1
                                                rust-uuid-1.28.0
                                                rust-vcpkg-0.2.15
                                                rust-version-check-0.9.5
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasm-bindgen-0.2.129
                                                rust-wasm-bindgen-macro-0.2.129
                                                rust-wasm-bindgen-macro-support-0.2.129
                                                rust-wasm-bindgen-shared-0.2.129
                                                rust-which-8.0.6
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.11
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.62.2
                                                rust-windows-collections-0.3.2
                                                rust-windows-core-0.62.2
                                                rust-windows-future-0.3.2
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.2.1
                                                rust-windows-numerics-0.3.1
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.61.2
                                                rust-windows-threading-0.2.1
                                                rust-windows-version-0.1.7
                                                rust-winnow-1.0.4
                                                rust-yubico-manager-0.9.0
                                                rust-zbus-5.19.0
                                                rust-zbus-macros-5.19.0
                                                rust-zbus-names-4.3.4
                                                rust-zcheapstr-1.1.0
                                                rust-zerocopy-0.8.63
                                                rust-zerocopy-derive-0.8.63
                                                rust-zeroize-1.9.1
                                                rust-zmij-1.0.23
                                                rust-zvariant-5.15.0
                                                rust-zvariant-derive-5.15.0
                                                rust-zvariant-utils-4.2.0))

                     (nix-ld =>
                              (list rust-byteorder-1.5.0
                               rust-cc-1.10.0
                               rust-embedded-io-0.7.1
                               rust-find-msvc-tools-0.1.15
                               rust-goblin-0.10.7
                               rust-hash32-0.3.1
                               rust-heapless-0.9.3
                               rust-linux-raw-sys-0.12.1
                               rust-log-0.4.34
                               rust-plain-0.2.3
                               rust-scroll-0.13.0
                               rust-shlex-2.0.1
                               rust-stable-deref-trait-1.2.0))

                     (helix-steel =>
                              (list rust-abi-stable-0.11.3
                                    rust-abi-stable-derive-0.11.3
                                    rust-abi-stable-shared-0.11.0
                                    rust-ahash-0.8.12
                                    rust-aho-corasick-1.1.4
                                    rust-alloca-0.4.0
                                    rust-allocator-api2-0.2.21
                                    rust-android-system-properties-0.1.5
                                    rust-anes-0.1.6
                                    rust-anstyle-1.0.14
                                    rust-anyhow-1.0.102
                                    rust-anymap3-1.1.0
                                    rust-arc-swap-1.9.1
                                    rust-arrayvec-0.5.2
                                    rust-arrayvec-0.7.7
                                    rust-as-derive-utils-0.11.0
                                    rust-async-ffi-0.5.0
                                    rust-autocfg-1.5.1
                                    rust-bigdecimal-0.4.10
                                    rust-bincode-1.3.3
                                    rust-bitflags-1.3.2
                                    rust-bitflags-2.13.0
                                    rust-bitmaps-2.1.0
                                    rust-bitmaps-3.2.1
                                    rust-block-buffer-0.10.4
                                    rust-bstr-1.12.1
                                    rust-bumpalo-3.20.3
                                    rust-bytemuck-1.25.0
                                    rust-byteorder-1.5.0
                                    rust-bytes-1.12.0
                                    rust-cassowary-0.3.0
                                    rust-cast-0.3.0
                                    rust-castaway-0.2.4
                                    rust-cc-1.2.65
                                    rust-cfg-if-1.0.4
                                    rust-chardetng-1.0.0
                                    rust-chrono-0.4.45
                                    rust-ciborium-0.2.2
                                    rust-ciborium-io-0.2.2
                                    rust-ciborium-ll-0.2.2
                                    rust-clap-4.6.1
                                    rust-clap-builder-4.6.0
                                    rust-clap-lex-1.1.0
                                    rust-clipboard-win-5.4.1
                                    rust-clru-0.6.3
                                    rust-codegen-0.2.0
                                    rust-codespan-reporting-0.11.1
                                    rust-compact-str-0.8.2
                                    rust-concurrent-queue-2.5.0
                                    rust-const-panic-0.2.15
                                    rust-convert-case-0.10.0
                                    rust-coolor-1.1.0
                                    rust-core-foundation-sys-0.8.7
                                    rust-core-extensions-1.5.4
                                    rust-core-extensions-proc-macros-1.5.4
                                    rust-cpufeatures-0.2.17
                                    rust-crc32fast-1.5.0
                                    rust-criterion-0.8.2
                                    rust-criterion-plot-0.8.2
                                    rust-crokey-1.4.0
                                    rust-crokey-proc-macros-1.4.0
                                    rust-crossbeam-0.8.4
                                    rust-crossbeam-channel-0.5.15
                                    rust-crossbeam-deque-0.8.6
                                    rust-crossbeam-epoch-0.9.18
                                    rust-crossbeam-queue-0.3.12
                                    rust-crossbeam-utils-0.8.21
                                    rust-crossterm-0.28.1
                                    rust-crossterm-0.29.0
                                    rust-crossterm-winapi-0.9.1
                                    rust-crunchy-0.2.4
                                    rust-crypto-common-0.1.7
                                    rust-dashmap-6.2.1
                                    rust-defmt-1.1.0
                                    rust-defmt-macros-1.1.0
                                    rust-defmt-parser-1.0.0
                                    rust-derive-more-2.1.1
                                    rust-derive-more-impl-2.1.1
                                    rust-digest-0.10.7
                                    rust-displaydoc-0.2.6
                                    rust-document-features-0.2.12
                                    rust-dunce-1.0.5
                                    rust-either-1.16.0
                                    rust-encoding-rs-0.8.35
                                    rust-encoding-rs-io-0.1.7
                                    rust-env-home-0.1.0
                                    rust-equivalent-1.0.2
                                    rust-errno-0.3.14
                                    rust-error-code-3.3.2
                                    rust-etcetera-0.11.0
                                    rust-faster-hex-0.10.0
                                    rust-fastrand-2.4.1
                                    rust-faststr-0.2.34
                                    rust-filetime-0.2.29
                                    rust-find-msvc-tools-0.1.9
                                    rust-fnv-1.0.7
                                    rust-foldhash-0.1.5
                                    rust-foldhash-0.2.0
                                    rust-futures-core-0.3.32
                                    rust-futures-executor-0.3.32
                                    rust-futures-macro-0.3.32
                                    rust-futures-task-0.3.32
                                    rust-futures-util-0.3.32
                                    rust-generational-arena-0.2.9
                                    rust-generic-array-0.14.7
                                    rust-generic-singleton-0.5.3
                                    rust-getrandom-0.3.4
                                    rust-getrandom-0.4.3
                                    rust-gix-0.84.0
                                    rust-gix-actor-0.41.1
                                    rust-gix-attributes-0.33.1
                                    rust-gix-bitmap-0.3.2
                                    rust-gix-chunk-0.7.2
                                    rust-gix-command-0.9.1
                                    rust-gix-commitgraph-0.37.1
                                    rust-gix-config-0.57.0
                                    rust-gix-config-value-0.18.1
                                    rust-gix-date-0.15.4
                                    rust-gix-diff-0.64.0
                                    rust-gix-dir-0.26.0
                                    rust-gix-discover-0.52.0
                                    rust-gix-error-0.2.4
                                    rust-gix-features-0.48.1
                                    rust-gix-filter-0.31.0
                                    rust-gix-fs-0.21.2
                                    rust-gix-glob-0.26.1
                                    rust-gix-hash-0.25.1
                                    rust-gix-hashtable-0.15.1
                                    rust-gix-ignore-0.21.1
                                    rust-gix-imara-diff-0.2.2
                                    rust-gix-index-0.52.0
                                    rust-gix-lock-23.0.1
                                    rust-gix-object-0.61.0
                                    rust-gix-odb-0.81.0
                                    rust-gix-pack-0.71.0
                                    rust-gix-packetline-0.21.5
                                    rust-gix-path-0.12.1
                                    rust-gix-pathspec-0.18.1
                                    rust-gix-protocol-0.62.0
                                    rust-gix-quote-0.7.2
                                    rust-gix-ref-0.64.0
                                    rust-gix-refspec-0.42.0
                                    rust-gix-revision-0.46.0
                                    rust-gix-revwalk-0.32.0
                                    rust-gix-sec-0.14.1
                                    rust-gix-shallow-0.12.1
                                    rust-gix-status-0.31.0
                                    rust-gix-submodule-0.31.0
                                    rust-gix-tempfile-23.0.1
                                    rust-gix-trace-0.1.20
                                    rust-gix-transport-0.57.1
                                    rust-gix-traverse-0.58.0
                                    rust-gix-url-0.36.1
                                    rust-gix-utils-0.3.3
                                    rust-gix-validate-0.11.2
                                    rust-gix-worktree-0.53.0
                                    rust-gix-worktree-stream-0.33.0
                                    rust-glob-0.3.3
                                    rust-globset-0.4.18
                                    rust-grep-matcher-0.1.8
                                    rust-grep-regex-0.1.14
                                    rust-grep-searcher-0.1.16
                                    rust-half-2.7.1
                                    rust-hash32-0.3.1
                                    rust-hashbrown-0.12.3
                                    rust-hashbrown-0.14.5
                                    rust-hashbrown-0.15.5
                                    rust-hashbrown-0.16.1
                                    rust-hashbrown-0.17.1
                                    rust-heapless-0.8.0
                                    rust-hermit-abi-0.5.2
                                    rust-home-0.5.12
                                    rust-httparse-1.10.1
                                    rust-iana-time-zone-0.1.65
                                    rust-iana-time-zone-haiku-0.1.2
                                    rust-icu-casemap-2.2.0
                                    rust-icu-casemap-data-2.2.0
                                    rust-icu-collections-2.2.0
                                    rust-icu-locale-core-2.2.0
                                    rust-icu-properties-2.2.0
                                    rust-icu-properties-data-2.2.0
                                    rust-icu-provider-2.2.0
                                    rust-ignore-0.4.26
                                    rust-im-15.1.0
                                    rust-im-lists-0.12.2
                                    rust-im-rc-15.1.0
                                    rust-imara-diff-0.2.0
                                    rust-imbl-sized-chunks-0.1.3
                                    rust-indexmap-1.9.3
                                    rust-indexmap-2.14.0
                                    rust-indoc-2.0.7
                                    rust-is-docker-0.2.0
                                    rust-is-wsl-0.4.0
                                    rust-itertools-0.13.0
                                    rust-itoa-1.0.18
                                    rust-jiff-0.2.29
                                    rust-jiff-static-0.2.29
                                    rust-jiff-tzdb-0.1.6
                                    rust-jiff-tzdb-platform-0.1.3
                                    rust-js-sys-0.3.102
                                    rust-kstring-2.0.2
                                    rust-lasso-0.7.3
                                    rust-lazy-regex-3.6.0
                                    rust-lazy-regex-proc-macros-3.6.0
                                    rust-libc-0.2.186
                                    rust-libloading-0.7.4
                                    rust-libloading-0.8.9
                                    rust-libm-0.2.16
                                    rust-linux-raw-sys-0.4.15
                                    rust-linux-raw-sys-0.12.1
                                    rust-litemap-0.8.2
                                    rust-litrs-1.0.0
                                    rust-lock-api-0.4.14
                                    rust-log-0.4.33
                                    rust-maybe-async-0.2.11
                                    rust-md-5-0.10.6
                                    rust-memchr-2.8.2
                                    rust-memmap2-0.9.10
                                    rust-minimad-0.13.1
                                    rust-mio-1.2.1
                                    rust-munge-0.4.7
                                    rust-munge-macro-0.4.7
                                    rust-nonempty-0.12.0
                                    rust-nucleo-0.5.0
                                    rust-nucleo-matcher-0.3.1
                                    rust-num-bigint-0.4.6
                                    rust-num-integer-0.1.46
                                    rust-num-rational-0.4.2
                                    rust-num-traits-0.2.19
                                    rust-num-cpus-1.17.0
                                    rust-once-cell-1.21.4
                                    rust-oorandom-11.1.5
                                    rust-open-5.3.5
                                    rust-ordered-float-5.3.0
                                    rust-page-size-0.6.0
                                    rust-parking-lot-0.12.5
                                    rust-parking-lot-core-0.9.12
                                    rust-paste-1.0.15
                                    rust-pathdiff-0.2.3
                                    rust-percent-encoding-2.3.2
                                    rust-pin-project-lite-0.2.17
                                    rust-polling-3.11.0
                                    rust-portable-atomic-1.13.1
                                    rust-portable-atomic-util-0.2.7
                                    rust-potential-utf-0.1.5
                                    rust-ppv-lite86-0.2.21
                                    rust-pretty-0.12.5
                                    rust-proc-macro-error-attr2-2.0.0
                                    rust-proc-macro-error2-2.0.1
                                    rust-proc-macro2-1.0.106
                                    rust-prodash-31.0.0
                                    rust-ptr-meta-0.3.1
                                    rust-ptr-meta-derive-0.3.1
                                    rust-pulldown-cmark-0.13.4
                                    rust-quickcheck-1.1.0
                                    rust-quote-1.0.45
                                    rust-r-efi-5.3.0
                                    rust-r-efi-6.0.0
                                    rust-rancor-0.1.1
                                    rust-rand-0.8.6
                                    rust-rand-0.9.4
                                    rust-rand-0.10.1
                                    rust-rand-chacha-0.9.0
                                    rust-rand-core-0.6.4
                                    rust-rand-core-0.9.5
                                    rust-rand-core-0.10.1
                                    rust-rand-xoshiro-0.6.0
                                    rust-rand-xoshiro-0.7.0
                                    rust-rayon-1.12.0
                                    rust-rayon-core-1.13.0
                                    rust-redox-syscall-0.5.18
                                    rust-ref-cast-1.0.25
                                    rust-ref-cast-impl-1.0.25
                                    rust-regex-1.12.4
                                    rust-regex-automata-0.4.14
                                    rust-regex-cursor-0.1.5
                                    rust-regex-syntax-0.8.11
                                    rust-rend-0.5.3
                                    rust-repr-offset-0.2.2
                                    rust-rkyv-0.8.16
                                    rust-rkyv-derive-0.8.16
                                    rust-ropey-1.6.1
                                    rust-rustc-hash-2.1.2
                                    rust-rustc-version-0.4.1
                                    rust-rustix-0.38.44
                                    rust-rustix-1.1.4
                                    rust-rustversion-1.0.22
                                    rust-ryu-1.0.23
                                    rust-safe-arch-0.7.4
                                    rust-same-file-1.0.6
                                    rust-scopeguard-1.2.0
                                    rust-semver-1.0.28
                                    rust-serde-1.0.228
                                    rust-serde-core-1.0.228
                                    rust-serde-derive-1.0.228
                                    rust-serde-json-1.0.150
                                    rust-serde-spanned-1.1.1
                                    rust-sha1-0.10.6
                                    rust-sha1-checked-0.10.0
                                    rust-sha2-0.10.9
                                    rust-shared-vector-0.4.5
                                    rust-shell-words-1.1.1
                                    rust-shlex-2.0.1
                                    rust-signal-hook-0.3.18
                                    rust-signal-hook-0.4.4
                                    rust-signal-hook-mio-0.2.5
                                    rust-signal-hook-registry-1.4.8
                                    rust-signal-hook-tokio-0.4.0
                                    rust-simdutf8-0.1.5
                                    rust-sized-chunks-0.6.5
                                    rust-slab-0.4.12
                                    rust-slotmap-1.1.1
                                    rust-smallvec-1.15.2
                                    rust-smartstring-1.0.1
                                    rust-smawk-0.3.3
                                    rust-socket2-0.6.4
                                    rust-sonic-number-0.1.2
                                    rust-sonic-rs-0.5.8
                                    rust-sonic-simd-0.1.4
                                    rust-stable-deref-trait-1.2.1
                                    rust-static-assertions-1.1.0
                                    rust-steel-core-0.8.3.118fb9f
                                    rust-steel-derive-0.8.3.118fb9f
                                    rust-steel-doc-0.8.3.118fb9f
                                    rust-steel-gen-0.8.3.118fb9f
                                    rust-steel-imbl-7.1.0
                                    rust-steel-parser-0.8.3.118fb9f
                                    rust-steel-quickscope-0.3.3.118fb9f
                                    rust-steel-rc-0.8.3.118fb9f
                                    rust-str-indices-0.4.4
                                    rust-strict-0.2.0
                                    rust-strsim-0.11.1
                                    rust-syn-1.0.109
                                    rust-syn-2.0.118
                                    rust-synstructure-0.13.2
                                    rust-tempfile-3.27.0
                                    rust-termcolor-1.4.1
                                    rust-termimad-0.31.3
                                    rust-termina-0.3.3
                                    rust-termini-1.0.0
                                    rust-textwrap-0.16.2
                                    rust-thin-vec-0.2.18
                                    rust-thiserror-2.0.18
                                    rust-thiserror-impl-2.0.18
                                    rust-threadpool-1.8.1
                                    rust-tinystr-0.8.3
                                    rust-tinytemplate-1.2.1
                                    rust-tinyvec-1.11.0
                                    rust-tinyvec-macros-0.1.1
                                    rust-tokio-1.52.3
                                    rust-tokio-macros-2.7.0
                                    rust-tokio-stream-0.1.18
                                    rust-toml-1.1.2+spec-1.1.0
                                    rust-toml-datetime-1.1.1+spec-1.1.0
                                    rust-toml-parser-1.1.2+spec-1.1.0
                                    rust-toml-writer-1.1.1+spec-1.1.0
                                    rust-tree-house-0.4.0
                                    rust-tree-house-bindings-0.3.2
                                    rust-tstr-0.2.4
                                    rust-tstr-proc-macros-0.2.2
                                    rust-typed-arena-2.0.2
                                    rust-typenum-1.20.1
                                    rust-typewit-1.15.2
                                    rust-uluru-3.1.0
                                    rust-unicase-2.9.0
                                    rust-unicode-bom-2.0.3
                                    rust-unicode-general-category-1.1.0
                                    rust-unicode-ident-1.0.24
                                    rust-unicode-linebreak-0.1.5
                                    rust-unicode-normalization-0.1.25
                                    rust-unicode-segmentation-1.13.3
                                    rust-unicode-width-0.1.12
                                    rust-unicode-width-0.2.2
                                    rust-utf8-iter-1.0.4
                                    rust-uuid-1.23.3
                                    rust-version-check-0.9.5
                                    rust-walkdir-2.5.0
                                    rust-wasi-0.11.1+wasi-snapshot-preview1
                                    rust-wasip2-1.0.4+wasi-0.2.12
                                    rust-wasm-bindgen-0.2.125
                                    rust-wasm-bindgen-macro-0.2.125
                                    rust-wasm-bindgen-macro-support-0.2.125
                                    rust-wasm-bindgen-shared-0.2.125
                                    rust-weak-table-0.3.2
                                    rust-which-8.0.4
                                    rust-wide-0.7.33
                                    rust-winapi-0.3.9
                                    rust-winapi-i686-pc-windows-gnu-0.4.0
                                    rust-winapi-util-0.1.11
                                    rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                    rust-windows-core-0.62.2
                                    rust-windows-implement-0.60.2
                                    rust-windows-interface-0.59.3
                                    rust-windows-link-0.2.1
                                    rust-windows-result-0.4.1
                                    rust-windows-strings-0.5.1
                                    rust-windows-sys-0.59.0
                                    rust-windows-sys-0.61.2
                                    rust-windows-targets-0.52.6
                                    rust-windows-aarch64-gnullvm-0.52.6
                                    rust-windows-aarch64-msvc-0.52.6
                                    rust-windows-i686-gnu-0.52.6
                                    rust-windows-i686-gnullvm-0.52.6
                                    rust-windows-i686-msvc-0.52.6
                                    rust-windows-x86-64-gnu-0.52.6
                                    rust-windows-x86-64-gnullvm-0.52.6
                                    rust-windows-x86-64-msvc-0.52.6
                                    rust-winnow-1.0.3
                                    rust-wit-bindgen-0.57.1
                                    rust-writeable-0.6.3
                                    rust-xdg-3.0.0
                                    rust-yoke-0.8.3
                                    rust-yoke-derive-0.8.2
                                    rust-zerocopy-0.8.52
                                    rust-zerocopy-derive-0.8.52
                                    rust-zerofrom-0.1.8
                                    rust-zerofrom-derive-0.1.7
                                    rust-zerotrie-0.2.4
                                    rust-zerovec-0.11.6
                                    rust-zerovec-derive-0.11.3
                                    rust-zlib-rs-0.6.3
                                    rust-zmij-1.0.21))

                     (nosd-blur =>
                                               (list
                                              rust-adler2-2.0.1
                                              rust-autocfg-1.5.1
                                              rust-bitflags-2.13.2
                                              rust-bytemuck-1.25.2
                                              rust-byteorder-lite-0.1.0
                                              rust-cfg-if-1.0.5
                                              rust-crc32fast-1.5.2
                                              rust-fdeflate-0.3.7
                                              rust-flate2-1.1.10
                                              rust-image-0.25.8
                                              rust-image-webp-0.2.4
                                              rust-miniz-oxide-0.8.9
                                              rust-miniz-oxide-0.9.1
                                              rust-moxcms-0.7.11
                                              rust-num-traits-0.2.19
                                              rust-png-0.18.1
                                              rust-pxfm-0.1.30
                                              rust-quick-error-2.0.1
                                              rust-simd-adler32-0.3.10
                                              rust-zlib-rs-0.6.8
                                              rust-zune-core-0.4.12
                                              rust-zune-jpeg-0.4.21))
                     (nosd-helpers =>
                                               (list
                                              rust-adler2-2.0.1
                                              rust-android-system-properties-0.1.6
                                              rust-anyhow-1.0.104
                                              rust-async-broadcast-0.7.2
                                              rust-async-channel-2.5.0
                                              rust-async-executor-1.14.0
                                              rust-async-io-2.6.0
                                              rust-async-lock-3.4.2
                                              rust-async-process-2.5.0
                                              rust-async-recursion-1.2.0
                                              rust-async-signal-0.2.14
                                              rust-async-task-4.7.1
                                              rust-async-trait-0.1.92
                                              rust-atomic-waker-1.1.2
                                              rust-autocfg-1.5.1
                                              rust-base64-0.23.1
                                              rust-bitflags-1.3.2
                                              rust-bitflags-2.13.2
                                              rust-blocking-1.7.0
                                              rust-bumpalo-3.20.3
                                              rust-bytes-1.12.1
                                              rust-cc-1.6.0
                                              rust-cfg-if-1.0.5
                                              rust-cfg-aliases-0.1.1
                                              rust-chrono-0.4.45
                                              rust-chrono-tz-0.10.4
                                              rust-concurrent-queue-2.5.0
                                              rust-core-foundation-sys-0.8.7
                                              rust-crc32fast-1.5.2
                                              rust-crossbeam-utils-0.8.23
                                              rust-downcast-rs-1.2.1
                                              rust-endi-1.1.1
                                              rust-enumflags2-0.7.12
                                              rust-enumflags2-derive-0.7.12
                                              rust-equivalent-1.0.2
                                              rust-errno-0.3.14
                                              rust-event-listener-5.4.2
                                              rust-event-listener-strategy-0.5.4
                                              rust-fastrand-2.5.0
                                              rust-filedescriptor-0.8.3
                                              rust-find-msvc-tools-0.1.14
                                              rust-flate2-1.1.10
                                              rust-futures-core-0.3.34
                                              rust-futures-io-0.3.34
                                              rust-futures-lite-2.6.1
                                              rust-futures-task-0.3.34
                                              rust-futures-util-0.3.34
                                              rust-getrandom-0.2.17
                                              rust-getrandom-0.4.3
                                              rust-hashbrown-0.17.1
                                              rust-hermit-abi-0.5.3
                                              rust-hex-0.4.3
                                              rust-http-1.5.0
                                              rust-httparse-1.10.1
                                              rust-iana-time-zone-0.1.65
                                              rust-iana-time-zone-haiku-0.1.2
                                              rust-indexmap-2.14.2
                                              rust-itoa-1.0.18
                                              rust-js-sys-0.3.106
                                              rust-lazy-static-1.5.1
                                              rust-libc-0.2.190
                                              rust-linux-raw-sys-0.12.1
                                              rust-log-0.4.34
                                              rust-memchr-2.8.3
                                              rust-memoffset-0.9.1
                                              rust-miniz-oxide-0.9.1
                                              rust-nix-0.28.0
                                              rust-num-traits-0.2.19
                                              rust-once-cell-1.21.4
                                              rust-ordered-stream-0.2.0
                                              rust-parking-2.2.1
                                              rust-percent-encoding-2.3.2
                                              rust-phf-0.12.1
                                              rust-phf-shared-0.12.1
                                              rust-pin-project-lite-0.2.17
                                              rust-piper-0.2.5
                                              rust-pkg-config-0.3.34
                                              rust-polling-3.11.0
                                              rust-portable-pty-0.9.0
                                              rust-proc-macro-crate-3.5.0
                                              rust-proc-macro2-1.0.107
                                              rust-quick-xml-0.41.0
                                              rust-quote-1.0.47
                                              rust-r-efi-6.0.0
                                              rust-ring-0.17.14
                                              rust-rustix-1.1.5
                                              rust-rustls-0.23.45
                                              rust-rustls-pki-types-1.15.1
                                              rust-rustls-webpki-0.103.15
                                              rust-rustversion-1.0.23
                                              rust-serde-1.0.229
                                              rust-serde-core-1.0.229
                                              rust-serde-derive-1.0.229
                                              rust-serde-json-1.0.151
                                              rust-serde-repr-0.1.21
                                              rust-serial2-0.2.38
                                              rust-shared-library-0.1.9
                                              rust-shell-words-1.1.1
                                              rust-shlex-2.0.1
                                              rust-signal-hook-registry-1.4.8
                                              rust-simd-adler32-0.3.10
                                              rust-siphasher-1.0.4
                                              rust-slab-0.4.12
                                              rust-smallvec-1.16.2
                                              rust-subtle-2.6.1
                                              rust-syn-2.0.119
                                              rust-syn-3.0.6
                                              rust-tempfile-3.27.0
                                              rust-thiserror-1.0.69
                                              rust-thiserror-impl-1.0.69
                                              rust-tokio-1.53.2
                                              rust-tokio-macros-2.7.2
                                              rust-toml-datetime-1.1.1+spec-1.1.0
                                              rust-toml-edit-0.25.15+spec-1.1.0
                                              rust-toml-parser-1.1.3+spec-1.1.0
                                              rust-tracing-0.1.44
                                              rust-tracing-attributes-0.1.31
                                              rust-tracing-core-0.1.36
                                              rust-uds-windows-1.2.1
                                              rust-unicode-ident-1.0.26
                                              rust-untrusted-0.9.0
                                              rust-ureq-3.4.2
                                              rust-ureq-proto-0.6.4
                                              rust-utf8-zero-0.8.1
                                              rust-uuid-1.27.0
                                              rust-wasi-0.11.1+wasi-snapshot-preview1
                                              rust-wasm-bindgen-0.2.129
                                              rust-wasm-bindgen-macro-0.2.129
                                              rust-wasm-bindgen-macro-support-0.2.129
                                              rust-wasm-bindgen-shared-0.2.129
                                              rust-wayland-backend-0.3.17
                                              rust-wayland-client-0.31.15
                                              rust-wayland-protocols-0.32.13
                                              rust-wayland-protocols-wlr-0.3.9
                                              rust-wayland-scanner-0.31.11
                                              rust-wayland-sys-0.31.11
                                              rust-webpki-roots-1.0.9
                                              rust-winapi-0.3.9
                                              rust-winapi-i686-pc-windows-gnu-0.4.0
                                              rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                              rust-windows-core-0.62.2
                                              rust-windows-implement-0.60.2
                                              rust-windows-interface-0.59.3
                                              rust-windows-link-0.2.1
                                              rust-windows-result-0.4.1
                                              rust-windows-strings-0.5.1
                                              rust-windows-sys-0.52.0
                                              rust-windows-sys-0.61.2
                                              rust-windows-targets-0.52.6
                                              rust-windows-aarch64-gnullvm-0.52.6
                                              rust-windows-aarch64-msvc-0.52.6
                                              rust-windows-i686-gnu-0.52.6
                                              rust-windows-i686-gnullvm-0.52.6
                                              rust-windows-i686-msvc-0.52.6
                                              rust-windows-x86-64-gnu-0.52.6
                                              rust-windows-x86-64-gnullvm-0.52.6
                                              rust-windows-x86-64-msvc-0.52.6
                                              rust-winnow-1.0.4
                                              rust-winreg-0.10.1
                                              rust-zbus-5.19.0
                                              rust-zbus-macros-5.19.0
                                              rust-zbus-names-4.3.4
                                              rust-zcheapstr-1.1.0
                                              rust-zeroize-1.9.0
                                              rust-zlib-rs-0.6.8
                                              rust-zmij-1.0.23
                                              rust-zvariant-5.15.0
                                              rust-zvariant-derive-5.15.0
                                              rust-zvariant-utils-4.2.0))
                     (nosd-theme =>
                                               (list
                                              rust-adler2-2.0.1
                                              rust-cfg-if-1.0.5
                                              rust-crc32fast-1.5.2
                                              rust-equivalent-1.0.2
                                              rust-flate2-1.1.2
                                              rust-hashbrown-0.17.1
                                              rust-indexmap-2.14.2
                                              rust-itoa-1.0.18
                                              rust-memchr-2.8.3
                                              rust-miniz-oxide-0.8.9
                                              rust-proc-macro2-1.0.107
                                              rust-quote-1.0.47
                                              rust-serde-1.0.229
                                              rust-serde-core-1.0.229
                                              rust-serde-derive-1.0.229
                                              rust-serde-json-1.0.151
                                              rust-serde-spanned-1.1.1
                                              rust-syn-3.0.6
                                              rust-toml-1.1.6+spec-1.1.0
                                              rust-toml-datetime-1.1.1+spec-1.1.0
                                              rust-toml-parser-1.1.3+spec-1.1.0
                                              rust-toml-writer-1.1.2+spec-1.1.0
                                              rust-unicode-ident-1.0.26
                                              rust-winnow-1.0.4
                                              rust-zmij-1.0.23))
                     (ai-usagebar =>
                                               (list rust-adler2-2.0.1
                                                rust-aead-0.6.1
                                                rust-aes-0.9.3
                                                rust-aes-gcm-0.11.1
                                                rust-aho-corasick-1.1.4
                                                rust-allocator-api2-0.2.21
                                                rust-android-system-properties-0.1.5
                                                rust-anstream-1.0.0
                                                rust-anstyle-1.0.14
                                                rust-anstyle-parse-1.0.0
                                                rust-anstyle-query-1.1.5
                                                rust-anstyle-wincon-3.0.11
                                                rust-anyhow-1.0.104
                                                rust-approx-0.5.1
                                                rust-assert-json-diff-2.0.2
                                                rust-atk-0.18.2
                                                rust-atk-sys-0.18.2
                                                rust-atomic-0.6.1
                                                rust-atomic-waker-1.1.2
                                                rust-autocfg-1.5.1
                                                rust-base64-0.22.1
                                                rust-base64-0.23.1
                                                rust-bit-set-0.5.3
                                                rust-bit-set-0.8.0
                                                rust-bit-vec-0.6.3
                                                rust-bit-vec-0.8.0
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.13.0
                                                rust-block-buffer-0.10.4
                                                rust-block-buffer-0.12.1
                                                rust-block-padding-0.4.2
                                                rust-block2-0.6.2
                                                rust-bumpalo-3.20.3
                                                rust-by-address-1.2.1
                                                rust-bytemuck-1.25.0
                                                rust-bytes-1.11.1
                                                rust-cairo-rs-0.18.5
                                                rust-cairo-sys-rs-0.18.2
                                                rust-castaway-0.2.4
                                                rust-cbc-0.2.1
                                                rust-cc-1.2.62
                                                rust-cesu8-1.1.0
                                                rust-cfg-aliases-0.2.1
                                                rust-cfg-expr-0.15.8
                                                rust-cfg-if-1.0.4
                                                rust-chacha20-0.10.2
                                                rust-chrono-0.4.45
                                                rust-cipher-0.5.2
                                                rust-clap-4.6.7
                                                rust-clap-builder-4.6.7
                                                rust-clap-derive-4.6.7
                                                rust-clap-lex-1.1.0
                                                rust-cmov-0.5.4
                                                rust-colorchoice-1.0.5
                                                rust-colored-3.1.1
                                                rust-combine-4.6.8
                                                rust-compact-str-0.9.1
                                                rust-console-0.16.3
                                                rust-convert-case-0.10.0
                                                rust-cookie-0.18.2
                                                rust-core-foundation-0.10.1
                                                rust-core-foundation-sys-0.8.7
                                                rust-core-graphics-0.25.0
                                                rust-core-graphics-types-0.2.0
                                                rust-cpubits-0.1.1
                                                rust-cpufeatures-0.2.17
                                                rust-cpufeatures-0.3.0
                                                rust-crc32fast-1.5.1
                                                rust-critical-section-1.2.0
                                                rust-crossbeam-channel-0.5.17
                                                rust-crossbeam-utils-0.8.23
                                                rust-crossterm-0.29.0
                                                rust-crossterm-winapi-0.9.1
                                                rust-crypto-common-0.1.7
                                                rust-crypto-common-0.2.2
                                                rust-csscolorparser-0.6.2
                                                rust-cssparser-0.37.0
                                                rust-cssparser-macros-0.7.1
                                                rust-ctr-0.10.1
                                                rust-ctrlc-3.5.2
                                                rust-ctutils-0.4.4
                                                rust-darling-0.20.11
                                                rust-darling-0.24.1
                                                rust-darling-core-0.20.11
                                                rust-darling-core-0.24.1
                                                rust-darling-macro-0.20.11
                                                rust-darling-macro-0.24.1
                                                rust-dbus-0.9.12
                                                rust-deltae-0.3.2
                                                rust-deranged-0.5.8
                                                rust-derive-more-2.1.1
                                                rust-derive-more-impl-2.1.1
                                                rust-diff-0.1.13
                                                rust-digest-0.10.7
                                                rust-digest-0.11.3
                                                rust-directories-6.0.0
                                                rust-dirs-7.0.0
                                                rust-dirs-sys-0.5.0
                                                rust-dispatch2-0.3.1
                                                rust-displaydoc-0.2.5
                                                rust-dlopen2-0.8.2
                                                rust-dlopen2-derive-0.4.3
                                                rust-document-features-0.2.12
                                                rust-dom-query-0.28.0
                                                rust-dpi-0.1.2
                                                rust-dtoa-1.0.11
                                                rust-dtoa-short-0.3.5
                                                rust-dunce-1.0.5
                                                rust-dyn-clone-1.0.20
                                                rust-either-1.16.0
                                                rust-encode-unicode-1.0.0
                                                rust-equivalent-1.0.2
                                                rust-errno-0.3.14
                                                rust-euclid-0.22.14
                                                rust-fallible-iterator-0.3.0
                                                rust-fallible-streaming-iterator-0.1.9
                                                rust-fancy-regex-0.11.0
                                                rust-fast-srgb8-1.0.0
                                                rust-fastrand-2.4.1
                                                rust-fdeflate-0.3.7
                                                rust-field-offset-0.3.6
                                                rust-filedescriptor-0.8.3
                                                rust-find-msvc-tools-0.1.9
                                                rust-finl-unicode-1.4.0
                                                rust-fixedbitset-0.4.2
                                                rust-flate2-1.1.10
                                                rust-fnv-1.0.7
                                                rust-foldhash-0.2.0
                                                rust-foreign-types-0.5.0
                                                rust-foreign-types-macros-0.2.4
                                                rust-foreign-types-shared-0.3.1
                                                rust-form-urlencoded-1.2.2
                                                rust-fs2-0.4.3
                                                rust-futures-0.3.32
                                                rust-futures-channel-0.3.32
                                                rust-futures-core-0.3.32
                                                rust-futures-executor-0.3.32
                                                rust-futures-io-0.3.34
                                                rust-futures-macro-0.3.32
                                                rust-futures-sink-0.3.32
                                                rust-futures-task-0.3.32
                                                rust-futures-util-0.3.32
                                                rust-gdk-0.18.2
                                                rust-gdk-pixbuf-0.18.5
                                                rust-gdk-pixbuf-sys-0.18.0
                                                rust-gdk-sys-0.18.2
                                                rust-gdkwayland-sys-0.18.2
                                                rust-gdkx11-0.18.2
                                                rust-gdkx11-sys-0.18.2
                                                rust-generic-array-0.14.7
                                                rust-gethostname-1.1.0
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.3.4
                                                rust-getrandom-0.4.3
                                                rust-ghash-0.6.0
                                                rust-gio-0.18.4
                                                rust-gio-sys-0.18.1
                                                rust-glib-0.18.5
                                                rust-glib-macros-0.18.5
                                                rust-glib-sys-0.18.1
                                                rust-global-hotkey-0.9.0
                                                rust-gobject-sys-0.18.0
                                                rust-gtk-0.18.2
                                                rust-gtk-sys-0.18.2
                                                rust-gtk3-macros-0.18.2
                                                rust-h2-0.4.16
                                                rust-hashbrown-0.16.1
                                                rust-hashbrown-0.17.1
                                                rust-heck-0.4.1
                                                rust-heck-0.5.0
                                                rust-hex-0.4.3
                                                rust-hmac-0.13.0
                                                rust-html5ever-0.39.0
                                                rust-http-1.4.0
                                                rust-http-body-1.0.1
                                                rust-http-body-util-0.1.3
                                                rust-httparse-1.10.1
                                                rust-httpdate-1.0.3
                                                rust-hybrid-array-0.4.14
                                                rust-hyper-1.9.0
                                                rust-hyper-rustls-0.27.9
                                                rust-hyper-util-0.1.20
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-icu-collections-2.2.0
                                                rust-icu-locale-core-2.2.0
                                                rust-icu-normalizer-2.2.0
                                                rust-icu-normalizer-data-2.2.0
                                                rust-icu-properties-2.2.0
                                                rust-icu-properties-data-2.2.0
                                                rust-icu-provider-2.2.0
                                                rust-ident-case-1.0.1
                                                rust-idna-1.1.0
                                                rust-idna-adapter-1.2.2
                                                rust-indexmap-2.14.0
                                                rust-indoc-2.0.7
                                                rust-inout-0.2.2
                                                rust-insta-1.49.0
                                                rust-instability-0.3.10
                                                rust-ipnet-2.12.0
                                                rust-is-terminal-polyfill-1.70.2
                                                rust-itertools-0.14.0
                                                rust-itoa-1.0.18
                                                rust-javascriptcore-rs-1.1.2
                                                rust-javascriptcore-rs-sys-1.1.1
                                                rust-jni-0.21.1
                                                rust-jni-sys-0.3.1
                                                rust-jni-sys-0.4.1
                                                rust-jni-sys-macros-0.4.1
                                                rust-js-sys-0.3.99
                                                rust-kasuari-0.4.12
                                                rust-keyboard-types-0.8.3
                                                rust-lab-0.11.0
                                                rust-lazy-static-1.5.0
                                                rust-libappindicator-0.9.0
                                                rust-libappindicator-sys-0.9.0
                                                rust-libc-0.2.186
                                                rust-libdbus-sys-0.2.7
                                                rust-libloading-0.7.4
                                                rust-libm-0.2.16
                                                rust-libredox-0.1.16
                                                rust-libsqlite3-sys-0.39.1
                                                rust-line-clipping-0.3.7
                                                rust-linux-raw-sys-0.12.1
                                                rust-litemap-0.8.2
                                                rust-litrs-1.0.0
                                                rust-lock-api-0.4.14
                                                rust-log-0.4.29
                                                rust-lru-0.18.2
                                                rust-lru-slab-0.1.2
                                                rust-mac-address-1.1.8
                                                rust-markup5ever-0.39.0
                                                rust-memchr-2.8.0
                                                rust-memmem-0.1.1
                                                rust-memoffset-0.9.1
                                                rust-minimal-lexical-0.2.1
                                                rust-miniz-oxide-0.8.9
                                                rust-miniz-oxide-0.9.1
                                                rust-mio-1.2.0
                                                rust-mockito-1.7.2
                                                rust-muda-0.21.1
                                                rust-ndk-0.9.0
                                                rust-ndk-context-0.1.1
                                                rust-ndk-sys-0.6.0+11769913
                                                rust-new-debug-unreachable-1.0.6
                                                rust-nix-0.29.0
                                                rust-nix-0.31.3
                                                rust-nom-7.1.3
                                                rust-num-conv-0.2.2
                                                rust-num-derive-0.4.2
                                                rust-num-enum-0.7.6
                                                rust-num-enum-derive-0.7.6
                                                rust-num-threads-0.1.7
                                                rust-num-traits-0.2.19
                                                rust-objc2-0.6.5
                                                rust-objc2-app-kit-0.3.2
                                                rust-objc2-cloud-kit-0.3.2
                                                rust-objc2-core-data-0.3.2
                                                rust-objc2-core-foundation-0.3.2
                                                rust-objc2-core-graphics-0.3.2
                                                rust-objc2-core-image-0.3.2
                                                rust-objc2-core-location-0.3.2
                                                rust-objc2-core-text-0.3.2
                                                rust-objc2-core-video-0.3.2
                                                rust-objc2-encode-4.1.0
                                                rust-objc2-exception-helper-0.1.1
                                                rust-objc2-foundation-0.3.2
                                                rust-objc2-io-surface-0.3.2
                                                rust-objc2-metal-0.3.2
                                                rust-objc2-quartz-core-0.3.2
                                                rust-objc2-ui-kit-0.3.2
                                                rust-objc2-user-notifications-0.3.2
                                                rust-objc2-web-kit-0.3.2
                                                rust-once-cell-1.21.4
                                                rust-once-cell-polyfill-1.70.2
                                                rust-openssl-probe-0.2.1
                                                rust-option-ext-0.2.0
                                                rust-ordered-float-4.6.0
                                                rust-palette-0.7.6
                                                rust-palette-derive-0.7.6
                                                rust-pango-0.18.3
                                                rust-pango-sys-0.18.0
                                                rust-parking-lot-0.12.5
                                                rust-parking-lot-core-0.9.12
                                                rust-pastey-0.2.3
                                                rust-pbkdf2-0.13.0
                                                rust-percent-encoding-2.3.2
                                                rust-pest-2.8.6
                                                rust-pest-derive-2.8.6
                                                rust-pest-generator-2.8.6
                                                rust-pest-meta-2.8.6
                                                rust-phf-0.11.3
                                                rust-phf-0.13.1
                                                rust-phf-codegen-0.11.3
                                                rust-phf-codegen-0.13.1
                                                rust-phf-generator-0.11.3
                                                rust-phf-generator-0.13.1
                                                rust-phf-macros-0.11.3
                                                rust-phf-macros-0.13.1
                                                rust-phf-shared-0.11.3
                                                rust-phf-shared-0.13.1
                                                rust-pin-project-lite-0.2.17
                                                rust-pkg-config-0.3.33
                                                rust-png-0.18.1
                                                rust-polyval-0.7.3
                                                rust-portable-atomic-1.13.1
                                                rust-potential-utf-0.1.5
                                                rust-powerfmt-0.2.0
                                                rust-ppv-lite86-0.2.21
                                                rust-precomputed-hash-0.1.1
                                                rust-pretty-assertions-1.4.1
                                                rust-proc-macro-crate-1.3.1
                                                rust-proc-macro-crate-2.0.2
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro-error-1.0.4
                                                rust-proc-macro-error-attr-1.0.4
                                                rust-proc-macro2-1.0.106
                                                rust-quinn-0.11.9
                                                rust-quinn-proto-0.11.18
                                                rust-quinn-udp-0.5.14
                                                rust-quote-1.0.45
                                                rust-r-efi-5.3.0
                                                rust-r-efi-6.0.0
                                                rust-rand-0.10.3
                                                rust-rand-0.8.6
                                                rust-rand-0.9.4
                                                rust-rand-chacha-0.9.0
                                                rust-rand-core-0.10.1
                                                rust-rand-core-0.6.4
                                                rust-rand-core-0.9.5
                                                rust-rand-pcg-0.10.2
                                                rust-ratatui-0.30.2
                                                rust-ratatui-bubbletea-components-0.2.0
                                                rust-ratatui-bubbletea-theme-0.2.0
                                                rust-ratatui-core-0.1.2
                                                rust-ratatui-crossterm-0.1.2
                                                rust-ratatui-macros-0.7.2
                                                rust-ratatui-termina-0.1.0
                                                rust-ratatui-termwiz-0.1.2
                                                rust-ratatui-widgets-0.3.2
                                                rust-raw-window-handle-0.6.2
                                                rust-redox-syscall-0.5.18
                                                rust-redox-users-0.5.2
                                                rust-ref-cast-1.0.27
                                                rust-ref-cast-impl-1.0.27
                                                rust-regex-1.12.3
                                                rust-regex-automata-0.4.14
                                                rust-regex-syntax-0.8.10
                                                rust-reqwest-0.12.28
                                                rust-ring-0.17.14
                                                rust-rmcp-3.8.0
                                                rust-rmcp-macros-3.8.0
                                                rust-rusqlite-0.41.1
                                                rust-rustc-hash-2.1.2
                                                rust-rustc-version-0.4.1
                                                rust-rustix-1.1.6
                                                rust-rustls-0.23.46
                                                rust-rustls-native-certs-0.8.4
                                                rust-rustls-pki-types-1.14.1
                                                rust-rustls-webpki-0.103.16
                                                rust-rustversion-1.0.22
                                                rust-ryu-1.0.23
                                                rust-same-file-1.0.6
                                                rust-schannel-0.1.29
                                                rust-schemars-1.2.3
                                                rust-schemars-derive-1.2.3
                                                rust-scopeguard-1.2.0
                                                rust-security-framework-3.7.0
                                                rust-security-framework-sys-2.17.0
                                                rust-selectors-0.38.0
                                                rust-semver-1.0.28
                                                rust-serde-1.0.229
                                                rust-serde-core-1.0.229
                                                rust-serde-derive-1.0.229
                                                rust-serde-derive-internals-0.30.0
                                                rust-serde-json-1.0.154
                                                rust-serde-spanned-0.6.9
                                                rust-serde-spanned-1.1.1
                                                rust-serde-urlencoded-0.7.1
                                                rust-servo-arc-0.4.3
                                                rust-sha1-0.11.0
                                                rust-sha2-0.10.9
                                                rust-sha2-0.11.1
                                                rust-shlex-1.3.0
                                                rust-signal-hook-0.3.18
                                                rust-signal-hook-mio-0.2.5
                                                rust-signal-hook-registry-1.4.8
                                                rust-simd-adler32-0.3.10
                                                rust-similar-2.7.0
                                                rust-siphasher-1.0.3
                                                rust-slab-0.4.12
                                                rust-smallvec-1.15.1
                                                rust-socket2-0.6.3
                                                rust-soup3-0.5.0
                                                rust-soup3-sys-0.5.0
                                                rust-stable-deref-trait-1.2.1
                                                rust-static-assertions-1.1.0
                                                rust-string-cache-0.9.0
                                                rust-string-cache-codegen-0.6.1
                                                rust-strsim-0.11.1
                                                rust-strum-0.28.0
                                                rust-strum-macros-0.28.0
                                                rust-subtle-2.6.1
                                                rust-syn-1.0.109
                                                rust-syn-2.0.117
                                                rust-syn-3.0.3
                                                rust-sync-wrapper-1.0.2
                                                rust-synstructure-0.13.2
                                                rust-system-deps-6.2.2
                                                rust-tao-0.37.2
                                                rust-tao-macros-0.1.4
                                                rust-target-lexicon-0.12.16
                                                rust-tempfile-3.27.0
                                                rust-tendril-0.5.1
                                                rust-termina-0.3.3
                                                rust-terminfo-0.9.0
                                                rust-termios-0.3.3
                                                rust-termwiz-0.23.3
                                                rust-thiserror-1.0.69
                                                rust-thiserror-2.0.21
                                                rust-thiserror-impl-1.0.69
                                                rust-thiserror-impl-2.0.21
                                                rust-time-0.3.47
                                                rust-time-core-0.1.8
                                                rust-time-macros-0.2.27
                                                rust-tinystr-0.8.3
                                                rust-tinyvec-1.11.0
                                                rust-tinyvec-macros-0.1.1
                                                rust-tokio-1.54.1
                                                rust-tokio-macros-2.7.0
                                                rust-tokio-rustls-0.26.4
                                                rust-tokio-util-0.7.18
                                                rust-toml-0.8.2
                                                rust-toml-1.1.6+spec-1.1.0
                                                rust-toml-datetime-0.6.3
                                                rust-toml-datetime-1.1.1+spec-1.1.0
                                                rust-toml-edit-0.19.15
                                                rust-toml-edit-0.20.2
                                                rust-toml-edit-0.25.15+spec-1.1.0
                                                rust-toml-parser-1.1.3+spec-1.1.0
                                                rust-toml-writer-1.1.2+spec-1.1.0
                                                rust-tower-0.5.3
                                                rust-tower-http-0.6.11
                                                rust-tower-layer-0.3.3
                                                rust-tower-service-0.3.3
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-tray-icon-0.26.1
                                                rust-try-lock-0.2.5
                                                rust-typenum-1.20.1
                                                rust-ucd-trie-0.1.7
                                                rust-unicode-ident-1.0.24
                                                rust-unicode-segmentation-1.13.2
                                                rust-unicode-truncate-2.0.1
                                                rust-unicode-width-0.2.3
                                                rust-universal-hash-0.6.1
                                                rust-untrusted-0.9.0
                                                rust-url-2.5.8
                                                rust-utf8-iter-1.0.4
                                                rust-utf8parse-0.2.2
                                                rust-uuid-1.23.2
                                                rust-vcpkg-0.2.15
                                                rust-version-check-0.9.5
                                                rust-version-compare-0.2.1
                                                rust-vtparse-0.6.2
                                                rust-walkdir-2.5.0
                                                rust-want-0.3.1
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasip2-1.0.1+wasi-0.2.4
                                                rust-wasm-bindgen-0.2.122
                                                rust-wasm-bindgen-futures-0.4.72
                                                rust-wasm-bindgen-macro-0.2.122
                                                rust-wasm-bindgen-macro-support-0.2.122
                                                rust-wasm-bindgen-shared-0.2.122
                                                rust-web-atoms-0.2.6
                                                rust-web-sys-0.3.99
                                                rust-web-time-1.1.0
                                                rust-webkit2gtk-2.0.2
                                                rust-webkit2gtk-sys-2.0.2
                                                rust-webpki-roots-1.0.10
                                                rust-webview2-com-0.39.1
                                                rust-webview2-com-macros-0.8.1
                                                rust-webview2-com-sys-0.39.1
                                                rust-wezterm-bidi-0.2.3
                                                rust-wezterm-blob-leases-0.1.1
                                                rust-wezterm-color-types-0.3.0
                                                rust-wezterm-dynamic-0.2.1
                                                rust-wezterm-dynamic-derive-0.1.1
                                                rust-wezterm-input-types-0.1.0
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.11
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.62.2
                                                rust-windows-aarch64-gnullvm-0.42.2
                                                rust-windows-aarch64-gnullvm-0.52.6
                                                rust-windows-aarch64-gnullvm-0.53.1
                                                rust-windows-aarch64-msvc-0.42.2
                                                rust-windows-aarch64-msvc-0.52.6
                                                rust-windows-aarch64-msvc-0.53.1
                                                rust-windows-collections-0.3.2
                                                rust-windows-core-0.62.2
                                                rust-windows-future-0.3.2
                                                rust-windows-i686-gnu-0.42.2
                                                rust-windows-i686-gnu-0.52.6
                                                rust-windows-i686-gnu-0.53.1
                                                rust-windows-i686-gnullvm-0.52.6
                                                rust-windows-i686-gnullvm-0.53.1
                                                rust-windows-i686-msvc-0.42.2
                                                rust-windows-i686-msvc-0.52.6
                                                rust-windows-i686-msvc-0.53.1
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.2.1
                                                rust-windows-numerics-0.3.1
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.45.0
                                                rust-windows-sys-0.52.0
                                                rust-windows-sys-0.59.0
                                                rust-windows-sys-0.60.2
                                                rust-windows-sys-0.61.2
                                                rust-windows-targets-0.42.2
                                                rust-windows-targets-0.52.6
                                                rust-windows-targets-0.53.5
                                                rust-windows-threading-0.2.1
                                                rust-windows-version-0.1.7
                                                rust-windows-x86-64-gnu-0.42.2
                                                rust-windows-x86-64-gnu-0.52.6
                                                rust-windows-x86-64-gnu-0.53.1
                                                rust-windows-x86-64-gnullvm-0.42.2
                                                rust-windows-x86-64-gnullvm-0.52.6
                                                rust-windows-x86-64-gnullvm-0.53.1
                                                rust-windows-x86-64-msvc-0.42.2
                                                rust-windows-x86-64-msvc-0.52.6
                                                rust-windows-x86-64-msvc-0.53.1
                                                rust-winnow-0.5.40
                                                rust-winnow-1.0.4
                                                rust-wit-bindgen-0.46.0
                                                rust-writeable-0.6.3
                                                rust-wry-0.57.1
                                                rust-x11-2.21.0
                                                rust-x11-dl-2.21.0
                                                rust-x11rb-0.13.2
                                                rust-x11rb-protocol-0.13.2
                                                rust-xkeysym-0.2.1
                                                rust-yansi-1.0.1
                                                rust-yoke-0.8.2
                                                rust-yoke-derive-0.8.2
                                                rust-zerocopy-0.8.48
                                                rust-zerocopy-derive-0.8.48
                                                rust-zerofrom-0.1.8
                                                rust-zerofrom-derive-0.1.7
                                                rust-zeroize-1.8.2
                                                rust-zerotrie-0.2.4
                                                rust-zerovec-0.11.6
                                                rust-zerovec-derive-0.11.3
                                                rust-zlib-rs-0.6.7
                                                rust-zmij-1.0.21))

                     (satty =>
                                               (list rust-adler2-2.0.1
                                                rust-android-system-properties-0.1.5
                                                rust-anstream-1.0.0
                                                rust-anstyle-1.0.14
                                                rust-anstyle-parse-1.0.0
                                                rust-anstyle-query-1.1.5
                                                rust-anstyle-wincon-3.0.11
                                                rust-anyhow-1.0.104
                                                rust-arraydeque-0.5.1
                                                rust-arrayvec-0.7.8
                                                rust-autocfg-1.5.1
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.13.1
                                                rust-bumpalo-3.20.3
                                                rust-bytemuck-1.25.2
                                                rust-bytemuck-derive-1.11.0
                                                rust-byteorder-lite-0.1.0
                                                rust-cairo-rs-0.21.5
                                                rust-cairo-sys-rs-0.21.5
                                                rust-cc-1.3.0
                                                rust-cfg-expr-0.20.8
                                                rust-cfg-if-1.0.4
                                                rust-chrono-0.4.45
                                                rust-clap-4.6.4
                                                rust-clap-builder-4.6.2
                                                rust-clap-complete-4.6.8
                                                rust-clap-complete-fig-4.5.2
                                                rust-clap-complete-nushell-4.6.1
                                                rust-clap-derive-4.6.4
                                                rust-clap-lex-1.1.0
                                                rust-clap-mangen-0.3.0
                                                rust-colorchoice-1.0.5
                                                rust-core-foundation-sys-0.8.7
                                                rust-core-maths-0.1.1
                                                rust-crc32fast-1.5.0
                                                rust-dlib-0.5.3
                                                rust-either-1.16.0
                                                rust-endi-1.1.1
                                                rust-epoxy-0.1.0
                                                rust-equivalent-1.0.2
                                                rust-errno-0.3.14
                                                rust-fastrand-2.5.0
                                                rust-fdeflate-0.3.7
                                                rust-femtovg-0.26.0
                                                rust-field-offset-0.3.6
                                                rust-find-msvc-tools-0.1.9
                                                rust-flate2-1.1.9
                                                rust-flume-0.12.0
                                                rust-fnv-1.0.7
                                                rust-fontconfig-0.11.0
                                                rust-fragile-2.1.0
                                                rust-futures-0.3.33
                                                rust-futures-channel-0.3.33
                                                rust-futures-core-0.3.33
                                                rust-futures-executor-0.3.33
                                                rust-futures-io-0.3.33
                                                rust-futures-macro-0.3.33
                                                rust-futures-sink-0.3.33
                                                rust-futures-task-0.3.33
                                                rust-futures-util-0.3.33
                                                rust-gdk-pixbuf-0.21.5
                                                rust-gdk-pixbuf-sys-0.21.5
                                                rust-gdk4-0.10.3
                                                rust-gdk4-sys-0.10.3
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.4.3
                                                rust-gio-0.21.5
                                                rust-gio-sys-0.21.5
                                                rust-gl-generator-0.9.0
                                                rust-glib-0.21.5
                                                rust-glib-macros-0.21.5
                                                rust-glib-sys-0.21.5
                                                rust-glow-0.18.0
                                                rust-gobject-sys-0.21.5
                                                rust-graphene-rs-0.21.5
                                                rust-graphene-sys-0.21.5
                                                rust-gsk4-0.10.3
                                                rust-gsk4-sys-0.10.3
                                                rust-gtk4-0.10.3
                                                rust-gtk4-macros-0.10.3
                                                rust-gtk4-sys-0.10.3
                                                rust-gvdb-0.10.0
                                                rust-hashbrown-0.17.1
                                                rust-heck-0.5.0
                                                rust-hex-color-3.0.0
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-image-0.25.10
                                                rust-imgref-1.12.2
                                                rust-indexmap-2.14.0
                                                rust-is-terminal-polyfill-1.70.2
                                                rust-itertools-0.15.0
                                                rust-itoa-1.0.18
                                                rust-js-sys-0.3.103
                                                rust-keycode-1.0.0
                                                rust-keycode-macro-1.0.0
                                                rust-khronos-api-2.2.0
                                                rust-lazy-static-1.5.0
                                                rust-libadwaita-0.8.1
                                                rust-libadwaita-sys-0.8.1
                                                rust-libc-0.2.186
                                                rust-libloading-0.8.9
                                                rust-libloading-0.9.0
                                                rust-libm-0.2.16
                                                rust-linux-raw-sys-0.12.1
                                                rust-lock-api-0.4.14
                                                rust-log-0.4.33
                                                rust-lru-0.18.1
                                                rust-memchr-2.8.3
                                                rust-memoffset-0.9.1
                                                rust-miniz-oxide-0.8.9
                                                rust-moxcms-0.8.1
                                                rust-num-traits-0.2.19
                                                rust-once-cell-1.21.4
                                                rust-once-cell-polyfill-1.70.2
                                                rust-pango-0.21.5
                                                rust-pango-sys-0.21.5
                                                rust-pin-project-lite-0.2.17
                                                rust-pkg-config-0.3.33
                                                rust-png-0.18.1
                                                rust-ppv-lite86-0.2.21
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro2-1.0.107
                                                rust-pxfm-0.1.30
                                                rust-quick-xml-0.39.4
                                                rust-quote-1.0.47
                                                rust-r-efi-6.0.0
                                                rust-rand-0.8.7
                                                rust-rand-chacha-0.3.1
                                                rust-rand-core-0.6.4
                                                rust-relm4-0.10.1
                                                rust-relm4-css-0.10.1
                                                rust-relm4-icons-0.10.1
                                                rust-relm4-icons-build-0.11.0
                                                rust-relm4-macros-0.10.1
                                                rust-resource-0.6.1
                                                rust-resource-list-proc-macro-0.6.1
                                                rust-rgb-0.8.53
                                                rust-roff-1.1.1
                                                rust-rustc-version-0.4.1
                                                rust-rustix-1.1.4
                                                rust-rustversion-1.0.23
                                                rust-rustybuzz-0.20.1
                                                rust-same-file-1.0.6
                                                rust-scopeguard-1.2.0
                                                rust-semver-1.0.28
                                                rust-serde-1.0.229
                                                rust-serde-core-1.0.229
                                                rust-serde-derive-1.0.229
                                                rust-serde-json-1.0.151
                                                rust-serde-spanned-1.1.1
                                                rust-shared-library-0.1.9
                                                rust-shlex-2.0.1
                                                rust-simd-adler32-0.3.10
                                                rust-slab-0.4.12
                                                rust-slotmap-1.1.1
                                                rust-smallvec-1.15.2
                                                rust-spin-0.9.9
                                                rust-strsim-0.11.1
                                                rust-syn-2.0.119
                                                rust-syn-3.0.2
                                                rust-system-deps-7.0.8
                                                rust-target-lexicon-0.13.5
                                                rust-tempfile-3.27.0
                                                rust-thiserror-2.0.19
                                                rust-thiserror-impl-2.0.19
                                                rust-tokio-1.53.1
                                                rust-toml-1.1.3+spec-1.1.0
                                                rust-toml-datetime-1.1.1+spec-1.1.0
                                                rust-toml-edit-0.25.13+spec-1.1.0
                                                rust-toml-parser-1.1.2+spec-1.1.0
                                                rust-toml-writer-1.1.2+spec-1.1.0
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-ttf-parser-0.25.1
                                                rust-unicode-bidi-0.3.18
                                                rust-unicode-bidi-mirroring-0.4.0
                                                rust-unicode-ccc-0.4.0
                                                rust-unicode-ident-1.0.24
                                                rust-unicode-properties-0.1.4
                                                rust-unicode-script-0.5.8
                                                rust-unicode-segmentation-1.13.3
                                                rust-utf8parse-0.2.2
                                                rust-version-check-0.9.5
                                                rust-version-compare-0.2.1
                                                rust-walkdir-2.5.0
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasm-bindgen-0.2.126
                                                rust-wasm-bindgen-macro-0.2.126
                                                rust-wasm-bindgen-macro-support-0.2.126
                                                rust-wasm-bindgen-shared-0.2.126
                                                rust-web-sys-0.3.103
                                                rust-winapi-util-0.1.11
                                                rust-windows-core-0.62.2
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.2.1
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.61.2
                                                rust-winnow-1.0.4
                                                rust-xdg-3.0.0
                                                rust-xml-rs-0.7.0
                                                rust-yeslogic-fontconfig-sys-6.0.1
                                                rust-zerocopy-0.8.54
                                                rust-zerocopy-derive-0.8.54
                                                rust-zmij-1.0.23
                                                rust-zvariant-5.13.1
                                                rust-zvariant-derive-5.13.1
                                                rust-zvariant-utils-3.5.0))

                     (fresh-editor =>
                                               (list rust-ab-glyph-0.2.32
                                                rust-ab-glyph-rasterizer-0.1.10
                                                rust-adler2-2.0.1
                                                rust-ahash-0.8.12
                                                rust-aho-corasick-1.1.4
                                                rust-alacritty-terminal-0.26.0
                                                rust-allocator-api2-0.2.21
                                                rust-android-activity-0.6.1
                                                rust-android-properties-0.2.2
                                                rust-android-system-properties-0.1.5
                                                rust-anstyle-1.0.14
                                                rust-anyhow-1.0.104
                                                rust-arboard-3.6.1
                                                rust-arrayref-0.3.9
                                                rust-arrayvec-0.7.6
                                                rust-as-raw-xcb-connection-1.0.1
                                                rust-ascii-1.1.0
                                                rust-ash-0.38.0+1.3.281
                                                rust-async-lock-3.4.2
                                                rust-async-trait-0.1.89
                                                rust-atk-0.18.2
                                                rust-atk-sys-0.18.2
                                                rust-atomic-0.6.1
                                                rust-atomic-waker-1.1.2
                                                rust-autocfg-1.5.0
                                                rust-base64-0.22.1
                                                rust-bincode-1.3.3
                                                rust-bindgen-0.72.1
                                                rust-bit-set-0.5.3
                                                rust-bit-set-0.8.0
                                                rust-bit-vec-0.6.3
                                                rust-bit-vec-0.8.0
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.11.1
                                                rust-bitvec-1.0.1
                                                rust-block-0.1.6
                                                rust-block-buffer-0.10.4
                                                rust-block-buffer-0.12.0
                                                rust-block2-0.5.1
                                                rust-bstr-1.12.1
                                                rust-bumpalo-3.20.2
                                                rust-bytemuck-1.25.0
                                                rust-bytemuck-derive-1.10.2
                                                rust-bytes-1.11.1
                                                rust-cairo-rs-0.18.5
                                                rust-cairo-sys-rs-0.18.2
                                                rust-calloop-0.13.0
                                                rust-calloop-wayland-source-0.3.0
                                                rust-castaway-0.2.4
                                                rust-cc-1.2.61
                                                rust-cesu8-1.1.0
                                                rust-cexpr-0.6.0
                                                rust-cfg-aliases-0.1.1
                                                rust-cfg-aliases-0.2.1
                                                rust-cfg-expr-0.15.8
                                                rust-cfg-if-1.0.4
                                                rust-chardetng-0.1.17
                                                rust-chrono-0.4.44
                                                rust-chunked-transfer-1.5.0
                                                rust-clang-sys-1.8.1
                                                rust-clap-4.6.1
                                                rust-clap-builder-4.6.0
                                                rust-clap-derive-4.6.1
                                                rust-clap-lex-1.1.0
                                                rust-clipboard-win-5.4.3
                                                rust-cobs-0.3.0
                                                rust-codespan-reporting-0.12.0
                                                rust-combine-4.6.7
                                                rust-compact-str-0.9.0
                                                rust-concurrent-queue-2.5.0
                                                rust-console-0.16.3
                                                rust-const-oid-0.10.2
                                                rust-const-random-0.1.18
                                                rust-const-random-macro-0.1.16
                                                rust-convert-case-0.10.0
                                                rust-core-foundation-0.10.1
                                                rust-core-foundation-0.9.4
                                                rust-core-foundation-sys-0.8.7
                                                rust-core-graphics-0.23.2
                                                rust-core-graphics-types-0.1.3
                                                rust-core-graphics-types-0.2.0
                                                rust-core-maths-0.1.1
                                                rust-cow-utils-0.1.3
                                                rust-cpufeatures-0.2.17
                                                rust-cpufeatures-0.3.0
                                                rust-crc32fast-1.5.0
                                                rust-crossbeam-channel-0.5.15
                                                rust-crossbeam-deque-0.8.6
                                                rust-crossbeam-epoch-0.9.21
                                                rust-crossbeam-utils-0.8.21
                                                rust-crossterm-0.29.0
                                                rust-crossterm-winapi-0.9.1
                                                rust-crunchy-0.2.4
                                                rust-crypto-common-0.1.7
                                                rust-crypto-common-0.2.1
                                                rust-csscolorparser-0.6.2
                                                rust-ctor-0.6.3
                                                rust-ctor-proc-macro-0.0.7
                                                rust-cursor-icon-1.2.0
                                                rust-darling-0.23.0
                                                rust-darling-core-0.23.0
                                                rust-darling-macro-0.23.0
                                                rust-deltae-0.3.2
                                                rust-deranged-0.5.8
                                                rust-derive-more-2.1.1
                                                rust-derive-more-impl-2.1.1
                                                rust-digest-0.10.7
                                                rust-digest-0.11.3
                                                rust-dirs-6.0.0
                                                rust-dirs-sys-0.5.0
                                                rust-dispatch-0.2.0
                                                rust-dispatch2-0.3.1
                                                rust-dlib-0.5.3
                                                rust-doctest-file-1.1.1
                                                rust-document-features-0.2.12
                                                rust-downcast-rs-1.2.1
                                                rust-dpi-0.1.2
                                                rust-dragonbox-ecma-0.1.12
                                                rust-dtor-0.1.1
                                                rust-dtor-proc-macro-0.0.6
                                                rust-dyn-clone-1.0.20
                                                rust-either-1.15.0
                                                rust-embedded-io-0.4.0
                                                rust-embedded-io-0.6.1
                                                rust-encode-unicode-1.0.0
                                                rust-encoding-rs-0.8.35
                                                rust-equivalent-1.0.2
                                                rust-errno-0.3.14
                                                rust-error-code-3.3.2
                                                rust-euclid-0.22.14
                                                rust-event-listener-5.4.1
                                                rust-event-listener-strategy-0.5.4
                                                rust-evictor-0.5.1
                                                rust-fancy-regex-0.11.0
                                                rust-fancy-regex-0.16.2
                                                rust-fastrand-2.4.1
                                                rust-fdeflate-0.3.7
                                                rust-field-offset-0.3.6
                                                rust-filedescriptor-0.8.3
                                                rust-filetime-0.2.29
                                                rust-find-msvc-tools-0.1.9
                                                rust-finl-unicode-1.4.0
                                                rust-fixedbitset-0.4.2
                                                rust-fixedbitset-0.5.7
                                                rust-flate2-1.1.9
                                                rust-fluent-uri-0.1.4
                                                rust-fnv-1.0.7
                                                rust-foldhash-0.1.5
                                                rust-foldhash-0.2.0
                                                rust-foreign-types-0.5.0
                                                rust-foreign-types-macros-0.2.3
                                                rust-foreign-types-shared-0.3.1
                                                rust-funty-2.0.0
                                                rust-futures-channel-0.3.32
                                                rust-futures-core-0.3.32
                                                rust-futures-executor-0.3.32
                                                rust-futures-io-0.3.32
                                                rust-futures-macro-0.3.32
                                                rust-futures-task-0.3.32
                                                rust-futures-util-0.3.32
                                                rust-gdk-0.18.2
                                                rust-gdk-pixbuf-0.18.5
                                                rust-gdk-pixbuf-sys-0.18.0
                                                rust-gdk-sys-0.18.2
                                                rust-generic-array-0.14.7
                                                rust-gethostname-1.1.0
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.3.4
                                                rust-getrandom-0.4.2
                                                rust-gio-0.18.4
                                                rust-gio-sys-0.18.1
                                                rust-gl-generator-0.14.0
                                                rust-glib-0.18.5
                                                rust-glib-macros-0.18.5
                                                rust-glib-sys-0.18.1
                                                rust-glob-0.3.3
                                                rust-globset-0.4.18
                                                rust-glow-0.16.0
                                                rust-glutin-wgl-sys-0.6.1
                                                rust-gobject-sys-0.18.0
                                                rust-gpu-allocator-0.28.0
                                                rust-gpu-descriptor-0.3.2
                                                rust-gpu-descriptor-types-0.2.0
                                                rust-gtk-0.18.2
                                                rust-gtk-sys-0.18.2
                                                rust-gtk3-macros-0.18.2
                                                rust-half-2.7.1
                                                rust-hashbrown-0.15.5
                                                rust-hashbrown-0.16.1
                                                rust-hashbrown-0.17.0
                                                rust-heck-0.4.1
                                                rust-heck-0.5.0
                                                rust-hermit-abi-0.5.2
                                                rust-hex-0.4.3
                                                rust-hexf-parse-0.2.1
                                                rust-home-0.5.12
                                                rust-http-1.4.0
                                                rust-httparse-1.10.1
                                                rust-httpdate-1.0.3
                                                rust-hybrid-array-0.4.11
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-id-arena-2.3.0
                                                rust-ident-case-1.0.1
                                                rust-ignore-0.4.25
                                                rust-include-dir-0.7.4
                                                rust-include-dir-macros-0.7.4
                                                rust-indexmap-2.14.0
                                                rust-indoc-2.0.7
                                                rust-inotify-0.11.1
                                                rust-inotify-sys-0.1.5
                                                rust-insta-1.47.2
                                                rust-instability-0.3.12
                                                rust-interprocess-2.4.2
                                                rust-is-docker-0.2.0
                                                rust-is-wsl-0.4.0
                                                rust-itertools-0.13.0
                                                rust-itertools-0.14.0
                                                rust-itoa-1.0.18
                                                rust-jni-0.21.1
                                                rust-jni-0.22.4
                                                rust-jni-macros-0.22.4
                                                rust-jni-sys-0.3.1
                                                rust-jni-sys-0.4.1
                                                rust-jni-sys-macros-0.4.1
                                                rust-jobserver-0.1.34
                                                rust-js-sys-0.3.97
                                                rust-jsonc-parser-0.34.0
                                                rust-kasuari-0.4.12
                                                rust-keyboard-types-0.7.0
                                                rust-khronos-api-3.1.0
                                                rust-khronos-egl-6.0.0
                                                rust-kqueue-1.1.1
                                                rust-kqueue-sys-1.1.0
                                                rust-lab-0.11.0
                                                rust-lazy-static-1.5.0
                                                rust-leb128fmt-0.1.0
                                                rust-libc-0.2.186
                                                rust-libloading-0.8.9
                                                rust-libm-0.2.16
                                                rust-libredox-0.1.16
                                                rust-libxdo-0.6.0
                                                rust-libxdo-sys-0.11.0
                                                rust-line-clipping-0.3.7
                                                rust-linked-hash-map-0.5.6
                                                rust-linux-raw-sys-0.12.1
                                                rust-linux-raw-sys-0.4.15
                                                rust-litrs-1.0.0
                                                rust-lock-api-0.4.14
                                                rust-log-0.4.29
                                                rust-lru-0.16.4
                                                rust-lsp-types-0.97.0
                                                rust-lyon-geom-1.0.19
                                                rust-lzma-sys-0.1.20
                                                rust-mac-address-1.1.8
                                                rust-malloc-buf-0.0.6
                                                rust-matchers-0.2.0
                                                rust-memchr-2.8.0
                                                rust-memmap2-0.9.10
                                                rust-memmem-0.1.1
                                                rust-memoffset-0.9.1
                                                rust-metal-0.33.0
                                                rust-minimal-lexical-0.2.1
                                                rust-miniz-oxide-0.8.9
                                                rust-mio-1.2.0
                                                rust-miow-0.6.1
                                                rust-muda-0.17.2
                                                rust-naga-28.0.0
                                                rust-ndk-0.9.0
                                                rust-ndk-context-0.1.1
                                                rust-ndk-sys-0.6.0+11769913
                                                rust-nix-0.28.0
                                                rust-nix-0.29.0
                                                rust-nix-0.31.3
                                                rust-nom-7.1.3
                                                rust-nom-8.0.0
                                                rust-nonmax-0.5.5
                                                rust-notify-8.2.0
                                                rust-notify-types-2.1.0
                                                rust-nu-ansi-term-0.50.3
                                                rust-num-bigint-0.4.6
                                                rust-num-conv-0.2.1
                                                rust-num-derive-0.4.2
                                                rust-num-enum-0.7.6
                                                rust-num-enum-derive-0.7.6
                                                rust-num-integer-0.1.46
                                                rust-num-threads-0.1.7
                                                rust-num-traits-0.2.19
                                                rust-objc-0.2.7
                                                rust-objc-sys-0.3.5
                                                rust-objc2-0.5.2
                                                rust-objc2-0.6.4
                                                rust-objc2-app-kit-0.2.2
                                                rust-objc2-app-kit-0.3.2
                                                rust-objc2-cloud-kit-0.2.2
                                                rust-objc2-contacts-0.2.2
                                                rust-objc2-core-data-0.2.2
                                                rust-objc2-core-foundation-0.3.2
                                                rust-objc2-core-graphics-0.3.2
                                                rust-objc2-core-image-0.2.2
                                                rust-objc2-core-location-0.2.2
                                                rust-objc2-encode-4.1.0
                                                rust-objc2-foundation-0.2.2
                                                rust-objc2-foundation-0.3.2
                                                rust-objc2-io-surface-0.3.2
                                                rust-objc2-link-presentation-0.2.2
                                                rust-objc2-metal-0.2.2
                                                rust-objc2-quartz-core-0.2.2
                                                rust-objc2-symbols-0.2.2
                                                rust-objc2-ui-kit-0.2.2
                                                rust-objc2-uniform-type-identifiers-0.2.2
                                                rust-objc2-user-notifications-0.2.2
                                                rust-once-cell-1.21.4
                                                rust-onig-6.5.3
                                                rust-onig-sys-69.9.3
                                                rust-open-5.3.4
                                                rust-openssl-probe-0.2.1
                                                rust-option-ext-0.2.0
                                                rust-orbclient-0.3.54
                                                rust-ordered-float-4.6.0
                                                rust-ordered-float-5.3.0
                                                rust-os-pipe-1.2.3
                                                rust-owned-ttf-parser-0.25.1
                                                rust-owo-colors-4.3.0
                                                rust-oxc-allocator-0.128.0
                                                rust-oxc-ast-0.128.0
                                                rust-oxc-ast-macros-0.128.0
                                                rust-oxc-ast-visit-0.128.0
                                                rust-oxc-browserslist-3.0.2
                                                rust-oxc-codegen-0.128.0
                                                rust-oxc-compat-0.128.0
                                                rust-oxc-data-structures-0.128.0
                                                rust-oxc-diagnostics-0.128.0
                                                rust-oxc-ecmascript-0.128.0
                                                rust-oxc-estree-0.128.0
                                                rust-oxc-index-4.1.0
                                                rust-oxc-isolated-declarations-0.128.0
                                                rust-oxc-miette-2.7.1
                                                rust-oxc-miette-derive-2.7.1
                                                rust-oxc-parser-0.128.0
                                                rust-oxc-regular-expression-0.128.0
                                                rust-oxc-semantic-0.128.0
                                                rust-oxc-span-0.128.0
                                                rust-oxc-str-0.128.0
                                                rust-oxc-syntax-0.128.0
                                                rust-oxc-transformer-0.128.0
                                                rust-oxc-traverse-0.128.0
                                                rust-pango-0.18.3
                                                rust-pango-sys-0.18.0
                                                rust-parking-lot-0.12.5
                                                rust-parking-lot-core-0.9.12
                                                rust-paste-1.0.15
                                                rust-pathdiff-0.2.3
                                                rust-percent-encoding-2.3.2
                                                rust-pest-2.8.6
                                                rust-pest-derive-2.8.6
                                                rust-pest-generator-2.8.6
                                                rust-pest-meta-2.8.6
                                                rust-petgraph-0.8.3
                                                rust-phf-0.11.3
                                                rust-phf-0.13.1
                                                rust-phf-codegen-0.11.3
                                                rust-phf-generator-0.11.3
                                                rust-phf-generator-0.13.1
                                                rust-phf-macros-0.11.3
                                                rust-phf-macros-0.13.1
                                                rust-phf-shared-0.11.3
                                                rust-phf-shared-0.13.1
                                                rust-pin-project-1.1.12
                                                rust-pin-project-internal-1.1.12
                                                rust-pin-project-lite-0.2.17
                                                rust-piper-0.2.5
                                                rust-pkg-config-0.3.33
                                                rust-plain-0.2.3
                                                rust-png-0.17.16
                                                rust-png-0.18.1
                                                rust-polling-3.11.0
                                                rust-portable-atomic-1.13.1
                                                rust-portable-atomic-util-0.2.7
                                                rust-portable-pty-0.9.0
                                                rust-postcard-1.1.3
                                                rust-powerfmt-0.2.0
                                                rust-ppv-lite86-0.2.21
                                                rust-presser-0.3.1
                                                rust-prettyplease-0.2.37
                                                rust-proc-macro-crate-1.3.1
                                                rust-proc-macro-crate-2.0.0
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro-error-1.0.4
                                                rust-proc-macro-error-attr-1.0.4
                                                rust-proc-macro2-1.0.106
                                                rust-profiling-1.0.18
                                                rust-proptest-1.11.0
                                                rust-pulldown-cmark-0.13.6
                                                rust-quick-error-1.2.3
                                                rust-quick-xml-0.39.4
                                                rust-quote-1.0.45
                                                rust-r-efi-5.3.0
                                                rust-r-efi-6.0.0
                                                rust-radium-0.7.0
                                                rust-rand-0.8.6
                                                rust-rand-0.9.4
                                                rust-rand-chacha-0.9.0
                                                rust-rand-core-0.6.4
                                                rust-rand-core-0.9.5
                                                rust-rand-xorshift-0.4.0
                                                rust-range-alloc-0.1.5
                                                rust-raqote-0.8.5
                                                rust-ratatui-0.30.0
                                                rust-ratatui-core-0.1.0
                                                rust-ratatui-crossterm-0.1.0
                                                rust-ratatui-termwiz-0.1.0
                                                rust-ratatui-wgpu-0.5.0
                                                rust-ratatui-widgets-0.3.0
                                                rust-raw-window-handle-0.6.2
                                                rust-recvmsg-1.0.0
                                                rust-redox-syscall-0.4.1
                                                rust-redox-syscall-0.5.18
                                                rust-redox-syscall-0.7.5
                                                rust-redox-users-0.5.2
                                                rust-ref-cast-1.0.25
                                                rust-ref-cast-impl-1.0.25
                                                rust-regex-1.12.3
                                                rust-regex-automata-0.4.14
                                                rust-regex-syntax-0.8.10
                                                rust-relative-path-2.0.1
                                                rust-renderdoc-sys-1.1.0
                                                rust-ring-0.17.14
                                                rust-ropey-1.6.1
                                                rust-rquickjs-0.11.0
                                                rust-rquickjs-core-0.11.0
                                                rust-rquickjs-macro-0.11.0
                                                rust-rquickjs-serde-0.5.0
                                                rust-rquickjs-sys-0.11.0
                                                rust-rustc-hash-1.1.0
                                                rust-rustc-hash-2.1.2
                                                rust-rustc-version-0.4.1
                                                rust-rustix-0.38.44
                                                rust-rustix-1.1.4
                                                rust-rustix-openpty-0.2.0
                                                rust-rustls-0.23.46
                                                rust-rustls-native-certs-0.8.3
                                                rust-rustls-pki-types-1.14.1
                                                rust-rustls-platform-verifier-0.6.2
                                                rust-rustls-platform-verifier-android-0.1.1
                                                rust-rustls-webpki-0.103.16
                                                rust-rustversion-1.0.22
                                                rust-rusty-fork-0.3.1
                                                rust-rustybuzz-0.20.1
                                                rust-ryu-1.0.23
                                                rust-same-file-1.0.6
                                                rust-schannel-0.1.29
                                                rust-schemars-1.2.1
                                                rust-schemars-derive-1.2.1
                                                rust-scoped-tls-1.0.1
                                                rust-scopeguard-1.2.0
                                                rust-sctk-adwaita-0.10.1
                                                rust-security-framework-3.7.0
                                                rust-security-framework-sys-2.17.0
                                                rust-self-cell-1.2.2
                                                rust-semver-1.0.28
                                                rust-seq-macro-0.3.6
                                                rust-serde-1.0.228
                                                rust-serde-core-1.0.228
                                                rust-serde-derive-1.0.228
                                                rust-serde-derive-internals-0.29.1
                                                rust-serde-json-1.0.149
                                                rust-serde-repr-0.1.20
                                                rust-serde-spanned-0.6.9
                                                rust-serde-spanned-1.1.1
                                                rust-serial2-0.2.36
                                                rust-sha1-0.11.0
                                                rust-sha2-0.10.9
                                                rust-sharded-slab-0.1.7
                                                rust-shared-library-0.1.9
                                                rust-shell-words-1.1.1
                                                rust-shlex-1.3.0
                                                rust-signal-hook-0.3.18
                                                rust-signal-hook-0.4.4
                                                rust-signal-hook-mio-0.2.5
                                                rust-signal-hook-registry-1.4.8
                                                rust-simd-adler32-0.3.9
                                                rust-simd-cesu8-1.1.1
                                                rust-simdutf8-0.1.5
                                                rust-similar-2.7.0
                                                rust-siphasher-1.0.3
                                                rust-slab-0.4.12
                                                rust-slotmap-1.1.1
                                                rust-smallvec-1.15.1
                                                rust-smawk-0.3.2
                                                rust-smithay-client-toolkit-0.19.2
                                                rust-smol-str-0.2.2
                                                rust-socket2-0.6.3
                                                rust-spirv-0.3.0+sdk-1.3.268.0
                                                rust-static-assertions-1.1.0
                                                rust-str-indices-0.4.4
                                                rust-streaming-iterator-0.1.9
                                                rust-strict-num-0.1.1
                                                rust-strsim-0.11.1
                                                rust-strum-0.27.2
                                                rust-strum-macros-0.27.2
                                                rust-subtle-2.6.1
                                                rust-sw-composite-0.7.16
                                                rust-syn-1.0.109
                                                rust-syn-2.0.117
                                                rust-syntect-5.3.0
                                                rust-system-deps-6.2.2
                                                rust-tap-1.0.1
                                                rust-tar-0.4.46
                                                rust-target-lexicon-0.12.16
                                                rust-tempfile-3.27.0
                                                rust-termcolor-1.4.1
                                                rust-terminfo-0.9.0
                                                rust-termios-0.3.3
                                                rust-termwiz-0.23.3
                                                rust-textwrap-0.16.2
                                                rust-thiserror-1.0.69
                                                rust-thiserror-2.0.18
                                                rust-thiserror-impl-1.0.69
                                                rust-thiserror-impl-2.0.18
                                                rust-thread-local-1.1.9
                                                rust-time-0.3.47
                                                rust-time-core-0.1.8
                                                rust-tiny-http-0.12.0
                                                rust-tiny-keccak-2.0.2
                                                rust-tiny-skia-0.11.4
                                                rust-tiny-skia-path-0.11.4
                                                rust-tokio-1.54.1
                                                rust-tokio-macros-2.7.0
                                                rust-toml-0.8.23
                                                rust-toml-1.1.2+spec-1.1.0
                                                rust-toml-datetime-0.6.11
                                                rust-toml-datetime-1.1.1+spec-1.1.0
                                                rust-toml-edit-0.19.15
                                                rust-toml-edit-0.20.7
                                                rust-toml-edit-0.22.27
                                                rust-toml-edit-0.25.11+spec-1.1.0
                                                rust-toml-parser-1.1.2+spec-1.1.0
                                                rust-toml-write-0.1.2
                                                rust-toml-writer-1.1.1+spec-1.1.0
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-tracing-log-0.2.0
                                                rust-tracing-subscriber-0.3.23
                                                rust-trash-5.2.6
                                                rust-tree-magic-mini-3.2.2
                                                rust-tree-sitter-0.26.8
                                                rust-tree-sitter-go-0.25.0
                                                rust-tree-sitter-highlight-0.26.8
                                                rust-tree-sitter-javascript-0.25.0
                                                rust-tree-sitter-json-0.24.8
                                                rust-tree-sitter-language-0.1.7
                                                rust-tree-sitter-templ-2.2.0
                                                rust-tree-sitter-typescript-0.23.2
                                                rust-ts-rs-12.0.1
                                                rust-ts-rs-macros-12.0.1
                                                rust-ttf-parser-0.25.1
                                                rust-typed-arena-2.0.2
                                                rust-typed-path-0.12.3
                                                rust-typenum-1.20.0
                                                rust-ucd-trie-0.1.7
                                                rust-unarray-0.1.4
                                                rust-unicase-2.9.0
                                                rust-unicode-bidi-0.3.18
                                                rust-unicode-bidi-mirroring-0.4.0
                                                rust-unicode-ccc-0.4.0
                                                rust-unicode-id-start-1.4.0
                                                rust-unicode-ident-1.0.24
                                                rust-unicode-linebreak-0.1.5
                                                rust-unicode-properties-0.1.4
                                                rust-unicode-script-0.5.8
                                                rust-unicode-segmentation-1.13.2
                                                rust-unicode-truncate-2.0.1
                                                rust-unicode-width-0.2.2
                                                rust-unicode-xid-0.2.6
                                                rust-untrusted-0.9.0
                                                rust-ureq-3.3.0
                                                rust-ureq-proto-0.6.0
                                                rust-urlencoding-2.1.3
                                                rust-utf8-zero-0.8.1
                                                rust-utf8parse-0.2.2
                                                rust-uuid-1.23.1
                                                rust-valuable-0.1.1
                                                rust-version-check-0.9.5
                                                rust-version-compare-0.2.1
                                                rust-vt100-0.16.2
                                                rust-vte-0.15.0
                                                rust-vtparse-0.6.2
                                                rust-wait-timeout-0.2.1
                                                rust-walkdir-2.5.0
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasip2-1.0.3+wasi-0.2.9
                                                rust-wasip3-0.4.0+wasi-0.3.0-rc-2026-01-06
                                                rust-wasm-bindgen-0.2.120
                                                rust-wasm-bindgen-futures-0.4.70
                                                rust-wasm-bindgen-macro-0.2.120
                                                rust-wasm-bindgen-macro-support-0.2.120
                                                rust-wasm-bindgen-shared-0.2.120
                                                rust-wasm-encoder-0.244.0
                                                rust-wasm-metadata-0.244.0
                                                rust-wasmparser-0.244.0
                                                rust-wayland-backend-0.3.15
                                                rust-wayland-client-0.31.14
                                                rust-wayland-csd-frame-0.3.0
                                                rust-wayland-cursor-0.31.14
                                                rust-wayland-protocols-0.32.12
                                                rust-wayland-protocols-plasma-0.3.12
                                                rust-wayland-protocols-wlr-0.3.12
                                                rust-wayland-scanner-0.31.10
                                                rust-wayland-sys-0.31.11
                                                rust-web-sys-0.3.97
                                                rust-web-time-1.1.0
                                                rust-webpki-root-certs-1.0.7
                                                rust-webpki-roots-1.0.10
                                                rust-wezterm-bidi-0.2.3
                                                rust-wezterm-blob-leases-0.1.1
                                                rust-wezterm-color-types-0.3.0
                                                rust-wezterm-dynamic-0.2.1
                                                rust-wezterm-dynamic-derive-0.1.1
                                                rust-wezterm-input-types-0.1.0
                                                rust-wgpu-28.0.0
                                                rust-wgpu-core-28.0.1
                                                rust-wgpu-core-deps-apple-28.0.0
                                                rust-wgpu-core-deps-emscripten-28.0.0
                                                rust-wgpu-core-deps-windows-linux-android-28.0.0
                                                rust-wgpu-hal-28.0.1
                                                rust-wgpu-types-28.0.0
                                                rust-which-8.0.6
                                                rust-widestring-1.2.1
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.11
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.56.0
                                                rust-windows-0.62.2
                                                rust-windows-aarch64-gnullvm-0.42.2
                                                rust-windows-aarch64-gnullvm-0.52.6
                                                rust-windows-aarch64-gnullvm-0.53.1
                                                rust-windows-aarch64-msvc-0.42.2
                                                rust-windows-aarch64-msvc-0.52.6
                                                rust-windows-aarch64-msvc-0.53.1
                                                rust-windows-collections-0.3.2
                                                rust-windows-core-0.56.0
                                                rust-windows-core-0.62.2
                                                rust-windows-future-0.3.2
                                                rust-windows-i686-gnu-0.42.2
                                                rust-windows-i686-gnu-0.52.6
                                                rust-windows-i686-gnu-0.53.1
                                                rust-windows-i686-gnullvm-0.52.6
                                                rust-windows-i686-gnullvm-0.53.1
                                                rust-windows-i686-msvc-0.42.2
                                                rust-windows-i686-msvc-0.52.6
                                                rust-windows-i686-msvc-0.53.1
                                                rust-windows-implement-0.56.0
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.56.0
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.2.1
                                                rust-windows-numerics-0.3.1
                                                rust-windows-result-0.1.2
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.45.0
                                                rust-windows-sys-0.52.0
                                                rust-windows-sys-0.59.0
                                                rust-windows-sys-0.60.2
                                                rust-windows-sys-0.61.2
                                                rust-windows-targets-0.42.2
                                                rust-windows-targets-0.52.6
                                                rust-windows-targets-0.53.5
                                                rust-windows-threading-0.2.1
                                                rust-windows-x86-64-gnu-0.42.2
                                                rust-windows-x86-64-gnu-0.52.6
                                                rust-windows-x86-64-gnu-0.53.1
                                                rust-windows-x86-64-gnullvm-0.42.2
                                                rust-windows-x86-64-gnullvm-0.52.6
                                                rust-windows-x86-64-gnullvm-0.53.1
                                                rust-windows-x86-64-msvc-0.42.2
                                                rust-windows-x86-64-msvc-0.52.6
                                                rust-windows-x86-64-msvc-0.53.1
                                                rust-winit-0.30.13
                                                rust-winnow-0.5.40
                                                rust-winnow-0.7.15
                                                rust-winnow-1.0.2
                                                rust-winreg-0.10.1
                                                rust-winresource-0.1.31
                                                rust-wit-bindgen-0.51.0
                                                rust-wit-bindgen-0.57.1
                                                rust-wit-bindgen-core-0.51.0
                                                rust-wit-bindgen-rust-0.51.0
                                                rust-wit-bindgen-rust-macro-0.51.0
                                                rust-wit-component-0.244.0
                                                rust-wit-parser-0.244.0
                                                rust-wl-clipboard-rs-0.9.3
                                                rust-wyz-0.5.1
                                                rust-x11-2.21.0
                                                rust-x11-dl-2.21.0
                                                rust-x11rb-0.13.2
                                                rust-x11rb-protocol-0.13.2
                                                rust-xattr-1.6.1
                                                rust-xcursor-0.3.10
                                                rust-xkbcommon-dl-0.4.2
                                                rust-xkeysym-0.2.1
                                                rust-xml-rs-0.8.28
                                                rust-xz2-0.1.7
                                                rust-yaml-rust-0.4.5
                                                rust-zerocopy-0.8.48
                                                rust-zerocopy-derive-0.8.48
                                                rust-zeroize-1.8.2
                                                rust-zip-9.0.3
                                                rust-zlib-rs-0.6.8
                                                rust-zmij-1.0.21
                                                rust-zopfli-0.8.3))

                     (zellij =>
                                               (list rust-addr2line-0.17.0
                                                rust-adler-1.0.2
                                                rust-ahash-0.8.11
                                                rust-aho-corasick-0.7.20
                                                rust-aho-corasick-1.0.1
                                                rust-allocator-api2-0.2.21
                                                rust-ambient-authority-0.0.2
                                                rust-android-system-properties-0.1.5
                                                rust-android-tzdata-0.1.1
                                                rust-ansi-term-0.12.1
                                                rust-anyhow-1.0.95
                                                rust-arc-swap-1.5.0
                                                rust-arrayvec-0.5.2
                                                rust-arrayvec-0.7.6
                                                rust-async-channel-1.8.0
                                                rust-async-trait-0.1.80
                                                rust-atomic-waker-1.0.0
                                                rust-atty-0.2.14
                                                rust-autocfg-1.1.0
                                                rust-aws-lc-rs-1.16.2
                                                rust-aws-lc-sys-0.39.0
                                                rust-axum-0.8.4
                                                rust-axum-core-0.5.2
                                                rust-axum-extra-0.10.1
                                                rust-axum-server-0.7.2
                                                rust-backtrace-0.3.65
                                                rust-backtrace-ext-0.2.1
                                                rust-base64-0.13.0
                                                rust-base64-0.22.1
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.11.0
                                                rust-block-buffer-0.10.4
                                                rust-bstr-1.5.0
                                                rust-bumpalo-3.16.0
                                                rust-byteorder-1.4.3
                                                rust-bytes-1.11.1
                                                rust-cap-fs-ext-3.4.4
                                                rust-cap-primitives-3.4.4
                                                rust-cap-rand-3.4.4
                                                rust-cap-std-3.4.4
                                                rust-cap-time-ext-3.4.4
                                                rust-cassowary-0.3.0
                                                rust-castaway-0.1.2
                                                rust-cc-1.2.57
                                                rust-cfg-if-1.0.0
                                                rust-chrono-0.4.39
                                                rust-clap-3.2.4
                                                rust-clap-complete-3.2.1
                                                rust-clap-derive-3.2.4
                                                rust-clap-lex-0.2.2
                                                rust-close-fds-0.3.2
                                                rust-cmake-0.1.54
                                                rust-colored-2.0.0
                                                rust-colorsys-0.6.5
                                                rust-concurrent-queue-2.2.0
                                                rust-console-0.15.0
                                                rust-cookie-0.18.1
                                                rust-core-foundation-0.10.1
                                                rust-core-foundation-sys-0.8.7
                                                rust-cpufeatures-0.2.2
                                                rust-crossbeam-0.8.1
                                                rust-crossbeam-channel-0.5.4
                                                rust-crossbeam-deque-0.8.1
                                                rust-crossbeam-epoch-0.9.8
                                                rust-crossbeam-queue-0.3.5
                                                rust-crossbeam-utils-0.8.15
                                                rust-crossterm-0.28.1
                                                rust-crossterm-winapi-0.9.1
                                                rust-crypto-common-0.1.6
                                                rust-ctor-0.1.22
                                                rust-curl-0.4.44
                                                rust-curl-sys-0.4.68+curl-8.4.0
                                                rust-daemonize-0.5.0
                                                rust-data-encoding-2.9.0
                                                rust-deranged-0.5.8
                                                rust-derivative-2.2.0
                                                rust-dialoguer-0.10.4
                                                rust-digest-0.10.7
                                                rust-directories-5.0.1
                                                rust-dirs-4.0.0
                                                rust-dirs-sys-0.3.7
                                                rust-dirs-sys-0.4.1
                                                rust-displaydoc-0.2.5
                                                rust-dissimilar-1.0.6
                                                rust-doctest-file-1.0.0
                                                rust-dunce-1.0.5
                                                rust-either-1.6.1
                                                rust-embed-resource-3.0.6
                                                rust-encode-unicode-0.3.6
                                                rust-encoding-rs-0.8.34
                                                rust-equivalent-1.0.1
                                                rust-erased-serde-0.3.20
                                                rust-errno-0.3.10
                                                rust-event-listener-2.5.2
                                                rust-expect-test-1.4.1
                                                rust-fallible-iterator-0.3.0
                                                rust-fallible-streaming-iterator-0.1.9
                                                rust-fastrand-1.7.0
                                                rust-fastrand-2.1.0
                                                rust-fd-lock-4.0.2
                                                rust-file-id-0.2.2
                                                rust-filetime-0.2.25
                                                rust-find-msvc-tools-0.1.9
                                                rust-fixedbitset-0.4.2
                                                rust-fnv-1.0.7
                                                rust-foldhash-0.1.4
                                                rust-form-urlencoded-1.2.1
                                                rust-fs-err-3.1.0
                                                rust-fs-extra-1.3.0
                                                rust-fs-set-times-0.20.1
                                                rust-fsevent-sys-4.1.0
                                                rust-futures-0.3.31
                                                rust-futures-channel-0.3.31
                                                rust-futures-core-0.3.31
                                                rust-futures-executor-0.3.31
                                                rust-futures-io-0.3.31
                                                rust-futures-lite-1.13.0
                                                rust-futures-macro-0.3.31
                                                rust-futures-sink-0.3.31
                                                rust-futures-task-0.3.31
                                                rust-futures-util-0.3.31
                                                rust-fuzzy-matcher-0.3.7
                                                rust-generic-array-0.14.5
                                                rust-getopts-0.2.21
                                                rust-getrandom-0.2.10
                                                rust-getrandom-0.3.1
                                                rust-ghost-0.1.4
                                                rust-gimli-0.26.1
                                                rust-globset-0.4.10
                                                rust-h2-0.4.10
                                                rust-hashbrown-0.11.2
                                                rust-hashbrown-0.14.5
                                                rust-hashbrown-0.15.2
                                                rust-hashlink-0.8.4
                                                rust-heck-0.4.0
                                                rust-heck-0.5.0
                                                rust-hermit-abi-0.1.19
                                                rust-hermit-abi-0.3.1
                                                rust-hermit-abi-0.5.2
                                                rust-highway-0.6.4
                                                rust-http-0.2.9
                                                rust-http-1.3.1
                                                rust-http-body-1.0.1
                                                rust-http-body-util-0.1.3
                                                rust-httparse-1.10.1
                                                rust-httpdate-1.0.3
                                                rust-humantime-2.1.0
                                                rust-hyper-1.6.0
                                                rust-hyper-util-0.1.11
                                                rust-iana-time-zone-0.1.60
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-icu-collections-2.1.1
                                                rust-icu-locale-core-2.1.1
                                                rust-icu-normalizer-2.1.1
                                                rust-icu-normalizer-data-2.1.1
                                                rust-icu-properties-2.1.2
                                                rust-icu-properties-data-2.1.2
                                                rust-icu-provider-2.1.1
                                                rust-idna-1.1.0
                                                rust-idna-adapter-1.2.1
                                                rust-ignore-0.4.20
                                                rust-include-dir-0.7.3
                                                rust-include-dir-macros-0.7.3
                                                rust-indexmap-1.8.2
                                                rust-indexmap-2.7.1
                                                rust-inotify-0.9.6
                                                rust-inotify-sys-0.1.5
                                                rust-insta-1.14.0
                                                rust-instant-0.1.12
                                                rust-interprocess-2.3.1
                                                rust-inventory-0.2.3
                                                rust-io-extras-0.18.4
                                                rust-io-lifetimes-1.0.10
                                                rust-io-lifetimes-2.0.3
                                                rust-ipnet-2.9.0
                                                rust-is-ci-1.1.1
                                                rust-is-terminal-0.4.7
                                                rust-isahc-1.7.2
                                                rust-itertools-0.10.5
                                                rust-itoa-1.0.14
                                                rust-jobserver-0.1.31
                                                rust-js-sys-0.3.64
                                                rust-kdl-4.5.0
                                                rust-kqueue-1.0.7
                                                rust-kqueue-sys-1.0.3
                                                rust-lazy-static-1.4.0
                                                rust-leb128-0.2.5
                                                rust-leb128fmt-0.1.0
                                                rust-lev-distance-0.1.1
                                                rust-libc-0.2.176
                                                rust-libm-0.2.15
                                                rust-libnghttp2-sys-0.1.8+1.55.1
                                                rust-libredox-0.1.3
                                                rust-libsqlite3-sys-0.27.0
                                                rust-libssh2-sys-0.2.23
                                                rust-libz-sys-1.1.8
                                                rust-linked-hash-map-0.5.4
                                                rust-linux-raw-sys-0.11.0
                                                rust-linux-raw-sys-0.3.7
                                                rust-linux-raw-sys-0.4.15
                                                rust-litemap-0.8.1
                                                rust-lock-api-0.4.11
                                                rust-log-0.4.17
                                                rust-log-mdc-0.1.0
                                                rust-log4rs-1.2.0
                                                rust-matchit-0.8.4
                                                rust-maybe-owned-0.3.4
                                                rust-memchr-2.7.6
                                                rust-memoffset-0.6.5
                                                rust-miette-5.8.0
                                                rust-miette-derive-5.8.0
                                                rust-mime-0.3.17
                                                rust-minimal-lexical-0.2.1
                                                rust-miniz-oxide-0.5.3
                                                rust-mio-0.8.11
                                                rust-mio-1.0.3
                                                rust-multimap-0.8.3
                                                rust-names-0.14.0
                                                rust-nix-0.23.1
                                                rust-nom-7.1.1
                                                rust-notify-6.1.1
                                                rust-notify-debouncer-full-0.3.2
                                                rust-ntapi-0.4.2
                                                rust-num-conv-0.2.0
                                                rust-num-cpus-1.17.0
                                                rust-num-traits-0.2.15
                                                rust-object-0.28.4
                                                rust-once-cell-1.21.3
                                                rust-openssl-probe-0.1.5
                                                rust-openssl-probe-0.2.1
                                                rust-openssl-src-300.5.4+3.5.4
                                                rust-openssl-sys-0.9.111
                                                rust-option-ext-0.2.0
                                                rust-os-str-bytes-6.1.0
                                                rust-owo-colors-3.4.0
                                                rust-parking-2.0.0
                                                rust-parking-lot-0.11.2
                                                rust-parking-lot-0.12.1
                                                rust-parking-lot-core-0.8.5
                                                rust-parking-lot-core-0.9.9
                                                rust-pem-3.0.6
                                                rust-percent-encoding-2.3.1
                                                rust-pest-2.7.15
                                                rust-petgraph-0.6.3
                                                rust-pin-project-1.1.3
                                                rust-pin-project-internal-1.1.3
                                                rust-pin-project-lite-0.2.14
                                                rust-pin-utils-0.1.0
                                                rust-pkg-config-0.3.25
                                                rust-polling-2.2.0
                                                rust-potential-utf-0.1.4
                                                rust-powerfmt-0.2.0
                                                rust-ppv-lite86-0.2.16
                                                rust-pretty-bytes-0.2.2
                                                rust-proc-macro-error-1.0.4
                                                rust-proc-macro-error-attr-1.0.4
                                                rust-proc-macro2-1.0.93
                                                rust-prost-0.11.9
                                                rust-prost-build-0.11.9
                                                rust-prost-derive-0.11.9
                                                rust-prost-types-0.11.9
                                                rust-quote-1.0.36
                                                rust-rand-0.8.5
                                                rust-rand-0.9.0
                                                rust-rand-chacha-0.3.1
                                                rust-rand-chacha-0.9.0
                                                rust-rand-core-0.6.3
                                                rust-rand-core-0.9.0
                                                rust-rcgen-0.13.2
                                                rust-recvmsg-1.0.0
                                                rust-redox-syscall-0.2.13
                                                rust-redox-syscall-0.4.1
                                                rust-redox-syscall-0.5.13
                                                rust-redox-users-0.4.3
                                                rust-regex-1.8.1
                                                rust-regex-syntax-0.7.1
                                                rust-ring-0.17.14
                                                rust-rusqlite-0.30.0
                                                rust-rustc-demangle-0.1.21
                                                rust-rustc-version-0.4.1
                                                rust-rustix-0.37.28
                                                rust-rustix-0.38.44
                                                rust-rustix-1.1.2
                                                rust-rustix-linux-procfs-0.1.1
                                                rust-rustls-0.23.27
                                                rust-rustls-native-certs-0.8.3
                                                rust-rustls-pemfile-2.2.0
                                                rust-rustls-pki-types-1.12.0
                                                rust-rustls-webpki-0.103.13
                                                rust-rustversion-1.0.20
                                                rust-ryu-1.0.10
                                                rust-same-file-1.0.6
                                                rust-scc-2.3.4
                                                rust-schannel-0.1.22
                                                rust-scopeguard-1.1.0
                                                rust-sdd-3.0.8
                                                rust-security-framework-3.7.0
                                                rust-security-framework-sys-2.17.0
                                                rust-semver-0.11.0
                                                rust-semver-1.0.27
                                                rust-semver-parser-0.10.2
                                                rust-serde-1.0.228
                                                rust-serde-core-1.0.228
                                                rust-serde-derive-1.0.228
                                                rust-serde-json-1.0.140
                                                rust-serde-path-to-error-0.1.17
                                                rust-serde-spanned-1.0.4
                                                rust-serde-urlencoded-0.7.1
                                                rust-serde-yaml-0.8.24
                                                rust-serial-test-3.2.0
                                                rust-serial-test-derive-3.2.0
                                                rust-sha1-0.10.6
                                                rust-sha2-0.10.8
                                                rust-shell-words-1.1.0
                                                rust-shellexpand-3.0.0
                                                rust-shlex-1.3.0
                                                rust-signal-hook-0.3.18
                                                rust-signal-hook-mio-0.2.5
                                                rust-signal-hook-registry-1.4.0
                                                rust-similar-2.1.0
                                                rust-sixel-image-0.2.1
                                                rust-sixel-tokenizer-0.1.0
                                                rust-slab-0.4.6
                                                rust-sluice-0.5.5
                                                rust-smallvec-1.13.2
                                                rust-smawk-0.3.1
                                                rust-socket2-0.4.9
                                                rust-socket2-0.5.7
                                                rust-spin-0.9.8
                                                rust-ssh2-0.9.3
                                                rust-stable-deref-trait-1.2.1
                                                rust-string-interner-0.19.0
                                                rust-strip-ansi-escapes-0.1.1
                                                rust-strip-ansi-escapes-0.2.1
                                                rust-strsim-0.10.0
                                                rust-strum-0.27.2
                                                rust-strum-macros-0.27.2
                                                rust-subtle-2.6.1
                                                rust-suggest-0.4.0
                                                rust-supports-color-2.0.0
                                                rust-supports-hyperlinks-2.1.0
                                                rust-supports-unicode-2.0.0
                                                rust-syn-1.0.96
                                                rust-syn-2.0.96
                                                rust-sync-wrapper-1.0.2
                                                rust-synstructure-0.13.2
                                                rust-sysinfo-0.33.1
                                                rust-system-interface-0.27.2
                                                rust-tempfile-3.10.1
                                                rust-termcolor-1.4.1
                                                rust-terminal-size-0.1.17
                                                rust-textwrap-0.15.0
                                                rust-thiserror-1.0.61
                                                rust-thiserror-2.0.12
                                                rust-thiserror-impl-1.0.61
                                                rust-thiserror-impl-2.0.12
                                                rust-thread-id-4.0.0
                                                rust-thread-local-1.1.7
                                                rust-time-0.3.47
                                                rust-time-core-0.1.8
                                                rust-time-macros-0.2.27
                                                rust-tinystr-0.8.2
                                                rust-tokio-1.44.2
                                                rust-tokio-macros-2.5.0
                                                rust-tokio-rustls-0.26.2
                                                rust-tokio-stream-0.1.18
                                                rust-tokio-tungstenite-0.20.1
                                                rust-tokio-tungstenite-0.26.2
                                                rust-tokio-util-0.7.15
                                                rust-toml-0.5.10
                                                rust-toml-0.9.6
                                                rust-toml-datetime-0.7.5+spec-1.1.0
                                                rust-toml-parser-1.0.9+spec-1.1.0
                                                rust-toml-writer-1.0.6+spec-1.1.0
                                                rust-tower-0.5.2
                                                rust-tower-http-0.6.4
                                                rust-tower-layer-0.3.3
                                                rust-tower-service-0.3.3
                                                rust-tracing-0.1.41
                                                rust-tracing-attributes-0.1.28
                                                rust-tracing-core-0.1.33
                                                rust-tracing-futures-0.2.5
                                                rust-tungstenite-0.20.1
                                                rust-tungstenite-0.26.2
                                                rust-typenum-1.15.0
                                                rust-typetag-0.1.8
                                                rust-typetag-impl-0.1.8
                                                rust-ucd-trie-0.1.7
                                                rust-unicode-ident-1.0.1
                                                rust-unicode-linebreak-0.1.2
                                                rust-unicode-width-0.1.10
                                                rust-unicode-width-0.2.1
                                                rust-untrusted-0.9.0
                                                rust-url-2.5.4
                                                rust-urlencoding-2.1.3
                                                rust-utf-8-0.7.6
                                                rust-utf8-iter-1.0.4
                                                rust-utf8parse-0.2.0
                                                rust-uuid-1.16.0
                                                rust-vcpkg-0.2.15
                                                rust-version-check-0.9.4
                                                rust-vswhom-0.1.0
                                                rust-vswhom-sys-0.1.3
                                                rust-vte-0.10.1
                                                rust-vte-0.11.0
                                                rust-vte-0.14.1
                                                rust-vte-generate-state-changes-0.1.1
                                                rust-waker-fn-1.1.0
                                                rust-walkdir-2.3.3
                                                rust-wasi-0.11.0+wasi-snapshot-preview1
                                                rust-wasi-0.13.3+wasi-0.2.2
                                                rust-wasi-common-34.0.2
                                                rust-wasm-bindgen-0.2.87
                                                rust-wasm-bindgen-backend-0.2.87
                                                rust-wasm-bindgen-macro-0.2.87
                                                rust-wasm-bindgen-macro-support-0.2.87
                                                rust-wasm-bindgen-shared-0.2.87
                                                rust-wasm-encoder-0.239.0
                                                rust-wasmi-0.51.5
                                                rust-wasmi-collections-0.51.5
                                                rust-wasmi-core-0.51.5
                                                rust-wasmi-ir-0.51.5
                                                rust-wasmi-wasi-0.51.5
                                                rust-wasmparser-0.228.0
                                                rust-wasmparser-0.239.0
                                                rust-wast-239.0.0
                                                rust-wast-35.0.2
                                                rust-wat-1.239.0
                                                rust-wepoll-ffi-0.1.2
                                                rust-which-4.2.5
                                                rust-widestring-1.2.1
                                                rust-wiggle-34.0.2
                                                rust-wiggle-generate-34.0.2
                                                rust-wiggle-macro-34.0.2
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.5
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.57.0
                                                rust-windows-aarch64-gnullvm-0.48.0
                                                rust-windows-aarch64-gnullvm-0.52.6
                                                rust-windows-aarch64-msvc-0.48.0
                                                rust-windows-aarch64-msvc-0.52.6
                                                rust-windows-core-0.52.0
                                                rust-windows-core-0.57.0
                                                rust-windows-i686-gnu-0.48.0
                                                rust-windows-i686-gnu-0.52.6
                                                rust-windows-i686-gnullvm-0.52.6
                                                rust-windows-i686-msvc-0.48.0
                                                rust-windows-i686-msvc-0.52.6
                                                rust-windows-implement-0.57.0
                                                rust-windows-interface-0.57.0
                                                rust-windows-result-0.1.2
                                                rust-windows-sys-0.48.0
                                                rust-windows-sys-0.52.0
                                                rust-windows-sys-0.59.0
                                                rust-windows-targets-0.48.0
                                                rust-windows-targets-0.52.6
                                                rust-windows-x86-64-gnu-0.48.0
                                                rust-windows-x86-64-gnu-0.52.6
                                                rust-windows-x86-64-gnullvm-0.48.0
                                                rust-windows-x86-64-gnullvm-0.52.6
                                                rust-windows-x86-64-msvc-0.48.0
                                                rust-windows-x86-64-msvc-0.52.6
                                                rust-winnow-0.7.15
                                                rust-winreg-0.55.0
                                                rust-winx-0.36.3
                                                rust-wit-bindgen-rt-0.33.0
                                                rust-witx-0.9.1
                                                rust-writeable-0.6.2
                                                rust-xflags-0.3.2
                                                rust-xflags-macros-0.3.2
                                                rust-xshell-0.2.2
                                                rust-xshell-macros-0.2.2
                                                rust-yaml-rust-0.4.5
                                                rust-yasna-0.5.2
                                                rust-yoke-0.8.1
                                                rust-yoke-derive-0.8.1
                                                rust-zerocopy-0.7.34
                                                rust-zerocopy-0.8.17
                                                rust-zerocopy-derive-0.7.34
                                                rust-zerocopy-derive-0.8.17
                                                rust-zerofrom-0.1.6
                                                rust-zerofrom-derive-0.1.6
                                                rust-zeroize-1.8.1
                                                rust-zerotrie-0.2.3
                                                rust-zerovec-0.11.5
                                                rust-zerovec-derive-0.11.2))

                     (flea =>
                                               (list rust-accesskit-0.24.1
                                                rust-accesskit-atspi-common-0.19.1
                                                rust-accesskit-consumer-0.38.0
                                                rust-accesskit-unix-0.22.1
                                                rust-addr2line-0.25.1
                                                rust-adler2-2.0.1
                                                rust-aes-0.8.4
                                                rust-ahash-0.8.12
                                                rust-aho-corasick-1.1.5
                                                rust-aligned-0.4.3
                                                rust-aligned-vec-0.6.4
                                                rust-allocator-api2-0.2.21
                                                rust-android-system-properties-0.1.6
                                                rust-anyhow-1.0.104
                                                rust-arbitrary-1.5.0
                                                rust-arg-enum-proc-macro-0.3.4
                                                rust-arrayref-0.3.9
                                                rust-arrayvec-0.7.8
                                                rust-as-raw-xcb-connection-1.0.1
                                                rust-as-slice-0.2.1
                                                rust-ash-0.38.0+1.3.281
                                                rust-ashpd-0.13.13
                                                rust-async-broadcast-0.7.2
                                                rust-async-channel-2.5.0
                                                rust-async-executor-1.14.0
                                                rust-async-fs-2.2.0
                                                rust-async-io-2.6.0
                                                rust-async-lock-3.4.2
                                                rust-async-net-2.0.0
                                                rust-async-process-2.5.0
                                                rust-async-recursion-1.2.0
                                                rust-async-signal-0.2.14
                                                rust-async-task-4.7.1
                                                rust-async-trait-0.1.92
                                                rust-atomic-0.5.3
                                                rust-atomic-waker-1.1.2
                                                rust-atspi-0.29.0
                                                rust-atspi-common-0.13.0
                                                rust-atspi-proxies-0.13.0
                                                rust-autocfg-1.5.1
                                                rust-av-scenechange-0.14.1
                                                rust-av1-grain-0.2.5
                                                rust-avif-serialize-0.8.9
                                                rust-backtrace-0.3.76
                                                rust-base64-0.23.1
                                                rust-bit-field-0.10.3
                                                rust-bit-set-0.11.1
                                                rust-bit-set-0.9.1
                                                rust-bit-vec-0.10.1
                                                rust-bit-vec-0.9.1
                                                rust-bitflags-1.3.2
                                                rust-bitflags-2.13.2
                                                rust-bitstream-io-4.10.0
                                                rust-block-0.1.6
                                                rust-block-buffer-0.10.4
                                                rust-block-padding-0.3.3
                                                rust-block2-0.6.2
                                                rust-blocking-1.7.0
                                                rust-borsh-1.8.1
                                                rust-borsh-derive-1.8.1
                                                rust-built-0.8.1
                                                rust-bumpalo-3.20.3
                                                rust-bytemuck-1.25.2
                                                rust-bytemuck-derive-1.12.1
                                                rust-byteorder-1.5.0
                                                rust-byteorder-lite-0.1.0
                                                rust-bytes-1.12.1
                                                rust-calloop-0.14.5
                                                rust-calloop-wayland-source-0.4.1
                                                rust-cbc-0.1.2
                                                rust-cc-1.8.0
                                                rust-cfg-aliases-0.2.2
                                                rust-cfg-if-1.0.5
                                                rust-chacha20-0.10.2
                                                rust-chrono-0.4.45
                                                rust-cipher-0.4.4
                                                rust-cocoa-0.25.0
                                                rust-cocoa-foundation-0.1.2
                                                rust-codespan-reporting-0.13.1
                                                rust-color-quant-1.1.0
                                                rust-concurrent-queue-2.5.0
                                                rust-const-random-0.1.18
                                                rust-const-random-macro-0.1.16
                                                rust-convert-case-0.10.0
                                                rust-convert-case-0.11.0
                                                rust-core-detect-1.0.0
                                                rust-core-foundation-0.10.1
                                                rust-core-foundation-0.9.4
                                                rust-core-foundation-sys-0.8.7
                                                rust-core-graphics-0.23.2
                                                rust-core-graphics-0.24.0
                                                rust-core-graphics-helmer-fork-0.24.0
                                                rust-core-graphics-types-0.1.3
                                                rust-core-graphics-types-0.2.0
                                                rust-core-maths-0.1.1
                                                rust-core-text-21.0.0
                                                rust-cosmic-text-0.19.0
                                                rust-cpufeatures-0.2.17
                                                rust-cpufeatures-0.3.1
                                                rust-crc32fast-1.5.2
                                                rust-crossbeam-deque-0.8.8
                                                rust-crossbeam-epoch-0.9.21
                                                rust-crossbeam-queue-0.3.14
                                                rust-crossbeam-utils-0.8.23
                                                rust-crunchy-0.2.4
                                                rust-crypto-common-0.1.7
                                                rust-ctor-1.0.13
                                                rust-data-url-0.3.2
                                                rust-deranged-0.5.9
                                                rust-derive-more-2.1.1
                                                rust-derive-more-impl-2.1.1
                                                rust-digest-0.10.7
                                                rust-dirs-5.0.1
                                                rust-dirs-sys-0.4.1
                                                rust-dispatch-0.2.0
                                                rust-dispatch2-0.3.1
                                                rust-displaydoc-0.2.7
                                                rust-dlib-0.5.3
                                                rust-document-features-0.2.12
                                                rust-downcast-rs-1.2.1
                                                rust-dwrote-0.11.5
                                                rust-dyn-clone-1.0.20
                                                rust-either-1.19.0
                                                rust-embed-resource-3.0.12
                                                rust-encoding-rs-0.8.42
                                                rust-endi-1.1.1
                                                rust-enumflags2-0.7.12
                                                rust-enumflags2-derive-0.7.12
                                                rust-enumn-0.1.14
                                                rust-equator-0.4.2
                                                rust-equator-macro-0.4.2
                                                rust-equivalent-1.0.3
                                                rust-errno-0.3.14
                                                rust-etagere-0.2.15
                                                rust-euclid-0.22.14
                                                rust-event-listener-5.4.2
                                                rust-event-listener-strategy-0.5.4
                                                rust-exr-1.74.2
                                                rust-fastrand-2.5.0
                                                rust-fax-0.2.7
                                                rust-fdeflate-0.3.7
                                                rust-filedescriptor-0.8.3
                                                rust-find-msvc-tools-0.1.14
                                                rust-fixedbitset-0.5.7
                                                rust-flate2-1.1.10
                                                rust-float-cmp-0.9.0
                                                rust-float-next-after-1.0.0
                                                rust-float-ord-0.3.2
                                                rust-flume-0.12.0
                                                rust-fnv-1.0.7
                                                rust-foldhash-0.1.5
                                                rust-foldhash-0.2.0
                                                rust-font-types-0.11.3
                                                rust-font-types-0.12.7
                                                rust-fontconfig-parser-0.5.8
                                                rust-fontdb-0.23.0
                                                rust-fontdb-0.24.0
                                                rust-foreign-types-0.5.0
                                                rust-foreign-types-macros-0.2.4
                                                rust-foreign-types-shared-0.3.1
                                                rust-form-urlencoded-1.2.2
                                                rust-freetype-sys-0.20.1
                                                rust-futures-0.3.34
                                                rust-futures-channel-0.3.34
                                                rust-futures-concurrency-7.7.1
                                                rust-futures-core-0.3.34
                                                rust-futures-executor-0.3.34
                                                rust-futures-io-0.3.34
                                                rust-futures-lite-2.6.1
                                                rust-futures-macro-0.3.34
                                                rust-futures-sink-0.3.34
                                                rust-futures-task-0.3.34
                                                rust-futures-util-0.3.34
                                                rust-generic-array-0.14.7
                                                rust-gethostname-1.1.0
                                                rust-getrandom-0.2.17
                                                rust-getrandom-0.3.4
                                                rust-getrandom-0.4.3
                                                rust-gif-0.14.2
                                                rust-gimli-0.32.3
                                                rust-gl-generator-0.14.0
                                                rust-glow-0.17.0
                                                rust-glutin-wgl-sys-0.6.1
                                                rust-gpu-allocator-0.28.0
                                                rust-gpu-descriptor-0.3.2
                                                rust-gpu-descriptor-types-0.2.0
                                                rust-half-2.7.1
                                                rust-harfrust-0.12.0
                                                rust-harfrust-0.5.2
                                                rust-hash32-0.3.1
                                                rust-hashbrown-0.14.5
                                                rust-hashbrown-0.15.5
                                                rust-hashbrown-0.16.1
                                                rust-hashbrown-0.17.1
                                                rust-heapless-0.9.3
                                                rust-heck-0.5.0
                                                rust-hermit-abi-0.5.3
                                                rust-hex-0.4.3
                                                rust-hexf-parse-0.2.1
                                                rust-hkdf-0.12.4
                                                rust-hmac-0.12.1
                                                rust-http-1.5.0
                                                rust-http-body-1.1.0
                                                rust-iana-time-zone-0.1.65
                                                rust-iana-time-zone-haiku-0.1.2
                                                rust-icu-collections-2.3.0
                                                rust-icu-locale-core-2.3.0
                                                rust-icu-normalizer-2.3.0
                                                rust-icu-normalizer-data-2.3.0
                                                rust-icu-properties-2.3.0
                                                rust-icu-properties-data-2.3.0
                                                rust-icu-provider-2.3.1
                                                rust-idna-1.1.0
                                                rust-idna-adapter-1.2.2
                                                rust-image-0.25.10
                                                rust-image-webp-0.2.4
                                                rust-imagesize-0.15.0
                                                rust-imgref-1.12.3
                                                rust-indexmap-2.14.2
                                                rust-inout-0.1.4
                                                rust-interpolate-name-0.2.4
                                                rust-inventory-0.3.25
                                                rust-is-docker-0.2.0
                                                rust-is-wsl-0.4.0
                                                rust-itertools-0.14.0
                                                rust-itoa-1.0.18
                                                rust-jni-sys-0.3.1
                                                rust-jni-sys-0.4.1
                                                rust-jni-sys-macros-0.4.1
                                                rust-jobserver-0.1.35
                                                rust-js-sys-0.3.106
                                                rust-khronos-api-3.1.0
                                                rust-khronos-egl-6.0.0
                                                rust-kurbo-0.13.1
                                                rust-lazy-static-1.5.1
                                                rust-lebe-0.5.3
                                                rust-libc-0.2.191
                                                rust-libfuzzer-sys-0.4.13
                                                rust-libloading-0.8.9
                                                rust-libm-0.2.16
                                                rust-libredox-0.1.25
                                                rust-linebender-resource-handle-0.1.1
                                                rust-link-section-0.19.3
                                                rust-linktime-proc-macro-0.2.3
                                                rust-linux-raw-sys-0.12.1
                                                rust-litemap-0.8.3
                                                rust-litrs-1.0.1
                                                rust-lock-api-0.4.14
                                                rust-log-0.4.34
                                                rust-loop9-0.1.5
                                                rust-lyon-1.0.19
                                                rust-lyon-algorithms-1.0.21
                                                rust-lyon-geom-1.0.19
                                                rust-lyon-path-1.0.19
                                                rust-lyon-tessellation-1.0.22
                                                rust-mac-notification-sys-0.6.15
                                                rust-malloc-buf-0.0.6
                                                rust-maybe-rayon-0.1.1
                                                rust-md-5-0.10.6
                                                rust-memchr-2.8.3
                                                rust-memmap2-0.9.11
                                                rust-memoffset-0.9.1
                                                rust-miniz-oxide-0.8.9
                                                rust-miniz-oxide-0.9.1
                                                rust-moxcms-0.8.1
                                                rust-multiversion-no-op-1.0.0
                                                rust-naga-29.0.4
                                                rust-ndk-sys-0.6.0+11769913
                                                rust-new-debug-unreachable-1.0.6
                                                rust-no-std-io2-0.9.4
                                                rust-nom-8.0.0
                                                rust-noop-proc-macro-0.3.0
                                                rust-notify-rust-4.18.2
                                                rust-ntapi-0.4.3
                                                rust-num-0.4.3
                                                rust-num-bigint-0.4.8
                                                rust-num-bigint-dig-0.9.1
                                                rust-num-complex-0.4.6
                                                rust-num-conv-0.2.2
                                                rust-num-cpus-1.17.0
                                                rust-num-derive-0.4.2
                                                rust-num-integer-0.1.47
                                                rust-num-iter-0.1.46
                                                rust-num-rational-0.4.2
                                                rust-num-traits-0.2.19
                                                rust-objc-0.2.7
                                                rust-objc-exception-0.1.2
                                                rust-objc-foundation-0.1.1
                                                rust-objc-id-0.1.1
                                                rust-objc2-0.6.5
                                                rust-objc2-core-foundation-0.3.2
                                                rust-objc2-core-video-0.3.2
                                                rust-objc2-encode-4.1.0
                                                rust-objc2-foundation-0.3.2
                                                rust-objc2-metal-0.3.2
                                                rust-objc2-quartz-core-0.3.2
                                                rust-object-0.37.3
                                                rust-omi-1.0.0
                                                rust-once-cell-1.21.4
                                                rust-oo7-0.6.0
                                                rust-open-5.4.4
                                                rust-option-ext-0.2.0
                                                rust-ordered-float-5.5.0
                                                rust-ordered-stream-0.2.0
                                                rust-parking-2.2.1
                                                rust-parking-lot-0.12.5
                                                rust-parking-lot-core-0.9.12
                                                rust-paste-1.0.15
                                                rust-pastey-0.1.1
                                                rust-pathfinder-geometry-0.5.1
                                                rust-pathfinder-simd-0.5.6
                                                rust-pbkdf2-0.12.2
                                                rust-percent-encoding-2.3.2
                                                rust-phf-0.13.1
                                                rust-phf-generator-0.13.1
                                                rust-phf-macros-0.13.1
                                                rust-phf-shared-0.13.1
                                                rust-pico-args-0.5.0
                                                rust-pin-project-1.1.13
                                                rust-pin-project-internal-1.1.13
                                                rust-pin-project-lite-0.2.17
                                                rust-piper-0.2.5
                                                rust-pkg-config-0.3.34
                                                rust-png-0.18.1
                                                rust-polling-3.11.0
                                                rust-pollster-0.2.5
                                                rust-pollster-0.4.0
                                                rust-polycool-0.4.0
                                                rust-portable-atomic-1.15.0
                                                rust-portable-atomic-util-0.2.8
                                                rust-postage-0.5.0
                                                rust-potential-utf-0.1.6
                                                rust-powerfmt-0.2.1
                                                rust-ppv-lite86-0.2.21
                                                rust-presser-0.3.1
                                                rust-proc-macro-crate-3.5.0
                                                rust-proc-macro2-1.0.107
                                                rust-profiling-1.0.18
                                                rust-profiling-procmacros-1.0.18
                                                rust-proptest-1.12.0
                                                rust-proptest-macro-0.6.0
                                                rust-pulp-0.22.3
                                                rust-pulp-wasm-simd-flag-0.1.1
                                                rust-pxfm-0.1.30
                                                rust-qoi-0.4.1
                                                rust-quick-error-1.2.3
                                                rust-quick-error-2.0.1
                                                rust-quick-xml-0.41.0
                                                rust-quote-1.0.47
                                                rust-r-efi-5.3.0
                                                rust-r-efi-6.0.0
                                                rust-rand-0.10.3
                                                rust-rand-0.8.8
                                                rust-rand-0.9.5
                                                rust-rand-chacha-0.3.1
                                                rust-rand-chacha-0.9.0
                                                rust-rand-core-0.10.1
                                                rust-rand-core-0.6.4
                                                rust-rand-core-0.9.5
                                                rust-rand-xorshift-0.5.0
                                                rust-range-alloc-0.1.5
                                                rust-rangemap-1.8.0
                                                rust-rav1e-0.8.1
                                                rust-ravif-0.13.0
                                                rust-raw-cpuid-11.6.0
                                                rust-raw-window-handle-0.6.2
                                                rust-raw-window-metal-1.1.0
                                                rust-rayon-1.12.0
                                                rust-rayon-core-1.13.0
                                                rust-read-fonts-0.37.0
                                                rust-read-fonts-0.41.0
                                                rust-reborrow-0.5.5
                                                rust-redox-syscall-0.5.18
                                                rust-redox-users-0.4.6
                                                rust-ref-cast-1.0.27
                                                rust-ref-cast-impl-1.0.27
                                                rust-regex-1.13.1
                                                rust-regex-automata-0.4.18
                                                rust-regex-syntax-0.8.11
                                                rust-renderdoc-sys-1.1.0
                                                rust-resvg-0.48.1
                                                rust-rgb-0.8.53
                                                rust-roxmltree-0.20.0
                                                rust-roxmltree-0.21.1
                                                rust-rustc-demangle-0.1.28
                                                rust-rustc-hash-1.1.0
                                                rust-rustc-hash-2.1.3
                                                rust-rustc-version-0.4.1
                                                rust-rustix-1.1.5
                                                rust-rustversion-1.0.23
                                                rust-rusty-fork-0.3.1
                                                rust-ryu-1.0.23
                                                rust-same-file-1.0.6
                                                rust-schemars-1.2.3
                                                rust-schemars-derive-1.2.3
                                                rust-scoped-tls-1.0.1
                                                rust-scopeguard-1.2.0
                                                rust-screencapturekit-0.2.8
                                                rust-screencapturekit-sys-0.2.8
                                                rust-seahash-4.1.0
                                                rust-self-cell-1.3.0
                                                rust-semver-1.0.28
                                                rust-serde-1.0.229
                                                rust-serde-bytes-0.11.19
                                                rust-serde-core-1.0.229
                                                rust-serde-derive-1.0.229
                                                rust-serde-derive-internals-0.30.0
                                                rust-serde-json-1.0.154
                                                rust-serde-repr-0.1.21
                                                rust-serde-spanned-1.1.2
                                                rust-serde-urlencoded-0.7.1
                                                rust-sha1-smol-1.0.1
                                                rust-sha2-0.10.9
                                                rust-shlex-2.0.1
                                                rust-signal-hook-registry-1.4.8
                                                rust-simd-adler32-0.3.10
                                                rust-simd-helpers-0.1.0
                                                rust-simdutf8-0.1.5
                                                rust-simplecss-0.2.2
                                                rust-siphasher-1.0.4
                                                rust-skrifa-0.40.0
                                                rust-skrifa-0.44.0
                                                rust-slab-0.4.12
                                                rust-slotmap-1.1.1
                                                rust-smallvec-1.16.3
                                                rust-smol-2.0.2
                                                rust-smol-str-0.3.6
                                                rust-spin-0.10.1
                                                rust-spin-0.9.9
                                                rust-spirv-0.4.0+sdk-1.4.341.0
                                                rust-stable-deref-trait-1.2.1
                                                rust-static-assertions-1.1.0
                                                rust-strict-num-0.1.1
                                                rust-strum-0.28.0
                                                rust-strum-macros-0.28.0
                                                rust-subtle-2.6.1
                                                rust-svg-fmt-0.4.5
                                                rust-svgtypes-0.16.1
                                                rust-swash-0.2.10
                                                rust-syn-2.0.119
                                                rust-syn-3.0.9
                                                rust-synstructure-0.14.0
                                                rust-sys-locale-0.3.2
                                                rust-sysinfo-0.31.4
                                                rust-taffy-0.13.0
                                                rust-tao-core-video-sys-0.2.0
                                                rust-tauri-winrt-notification-0.8.1
                                                rust-tempfile-3.27.0
                                                rust-termcolor-1.4.1
                                                rust-thiserror-1.0.69
                                                rust-thiserror-2.0.21
                                                rust-thiserror-impl-1.0.69
                                                rust-thiserror-impl-2.0.21
                                                rust-tiff-0.11.3
                                                rust-time-0.3.55
                                                rust-time-core-0.1.9
                                                rust-tiny-keccak-2.0.2
                                                rust-tiny-skia-0.12.0
                                                rust-tiny-skia-path-0.12.0
                                                rust-tinystr-0.8.4
                                                rust-tinyvec-1.13.3
                                                rust-tokio-1.53.3
                                                rust-toml-1.1.8+spec-1.1.0
                                                rust-toml-datetime-1.1.2+spec-1.1.0
                                                rust-toml-edit-0.25.17+spec-1.1.0
                                                rust-toml-parser-1.1.5+spec-1.1.0
                                                rust-toml-writer-1.1.3+spec-1.1.0
                                                rust-tracing-0.1.44
                                                rust-tracing-attributes-0.1.31
                                                rust-tracing-core-0.1.36
                                                rust-ttf-parser-0.25.1
                                                rust-typenum-1.20.1
                                                rust-uds-windows-1.2.1
                                                rust-unarray-0.1.4
                                                rust-unicode-bidi-0.3.18
                                                rust-unicode-ident-1.0.27
                                                rust-unicode-linebreak-0.1.5
                                                rust-unicode-normalization-0.1.25
                                                rust-unicode-script-0.5.8
                                                rust-unicode-segmentation-1.13.3
                                                rust-unicode-vo-0.1.0
                                                rust-unicode-width-0.2.2
                                                rust-url-2.5.8
                                                rust-usvg-0.48.1
                                                rust-utf8-iter-1.0.4
                                                rust-uuid-1.28.0
                                                rust-v-frame-0.3.9
                                                rust-version-check-0.9.5
                                                rust-vswhom-0.1.0
                                                rust-vswhom-sys-0.1.3
                                                rust-wait-timeout-0.2.1
                                                rust-waker-fn-1.2.0
                                                rust-walkdir-2.5.0
                                                rust-wasi-0.11.1+wasi-snapshot-preview1
                                                rust-wasip2-1.0.4+wasi-0.2.12
                                                rust-wasm-bindgen-0.2.129
                                                rust-wasm-bindgen-futures-0.4.79
                                                rust-wasm-bindgen-macro-0.2.129
                                                rust-wasm-bindgen-macro-support-0.2.129
                                                rust-wasm-bindgen-shared-0.2.129
                                                rust-wayland-backend-0.3.17
                                                rust-wayland-client-0.31.15
                                                rust-wayland-cursor-0.31.14
                                                rust-wayland-protocols-0.32.13
                                                rust-wayland-protocols-plasma-0.3.12
                                                rust-wayland-protocols-wlr-0.3.12
                                                rust-wayland-scanner-0.31.11
                                                rust-wayland-sys-0.31.11
                                                rust-web-sys-0.3.106
                                                rust-web-time-1.1.0
                                                rust-weezl-0.1.12
                                                rust-wgpu-29.0.4
                                                rust-wgpu-core-29.0.4
                                                rust-wgpu-core-deps-apple-29.0.4
                                                rust-wgpu-core-deps-emscripten-29.0.4
                                                rust-wgpu-core-deps-wasm-29.0.4
                                                rust-wgpu-core-deps-windows-linux-android-29.0.4
                                                rust-wgpu-hal-29.0.4
                                                rust-wgpu-naga-bridge-29.0.4
                                                rust-wgpu-types-29.0.4
                                                rust-which-8.0.6
                                                rust-winapi-0.3.9
                                                rust-winapi-i686-pc-windows-gnu-0.4.0
                                                rust-winapi-util-0.1.11
                                                rust-winapi-x86-64-pc-windows-gnu-0.4.0
                                                rust-windows-0.57.0
                                                rust-windows-0.61.3
                                                rust-windows-0.62.2
                                                rust-windows-aarch64-gnullvm-0.48.5
                                                rust-windows-aarch64-gnullvm-0.52.6
                                                rust-windows-aarch64-msvc-0.48.5
                                                rust-windows-aarch64-msvc-0.52.6
                                                rust-windows-capture-1.5.0
                                                rust-windows-collections-0.2.0
                                                rust-windows-collections-0.3.2
                                                rust-windows-core-0.57.0
                                                rust-windows-core-0.61.2
                                                rust-windows-core-0.62.2
                                                rust-windows-future-0.2.1
                                                rust-windows-future-0.3.2
                                                rust-windows-i686-gnu-0.48.5
                                                rust-windows-i686-gnu-0.52.6
                                                rust-windows-i686-gnullvm-0.52.6
                                                rust-windows-i686-msvc-0.48.5
                                                rust-windows-i686-msvc-0.52.6
                                                rust-windows-implement-0.57.0
                                                rust-windows-implement-0.60.2
                                                rust-windows-interface-0.57.0
                                                rust-windows-interface-0.59.3
                                                rust-windows-link-0.1.3
                                                rust-windows-link-0.2.1
                                                rust-windows-numerics-0.2.0
                                                rust-windows-numerics-0.3.1
                                                rust-windows-result-0.1.2
                                                rust-windows-result-0.3.4
                                                rust-windows-result-0.4.1
                                                rust-windows-strings-0.4.2
                                                rust-windows-strings-0.5.1
                                                rust-windows-sys-0.48.0
                                                rust-windows-sys-0.61.2
                                                rust-windows-targets-0.48.5
                                                rust-windows-targets-0.52.6
                                                rust-windows-threading-0.1.0
                                                rust-windows-threading-0.2.1
                                                rust-windows-version-0.1.7
                                                rust-windows-x86-64-gnu-0.48.5
                                                rust-windows-x86-64-gnu-0.52.6
                                                rust-windows-x86-64-gnullvm-0.48.5
                                                rust-windows-x86-64-gnullvm-0.52.6
                                                rust-windows-x86-64-msvc-0.48.5
                                                rust-windows-x86-64-msvc-0.52.6
                                                rust-winnow-1.0.4
                                                rust-winreg-0.56.0
                                                rust-wio-0.2.2
                                                rust-wit-bindgen-0.57.1
                                                rust-writeable-0.6.4
                                                rust-x11-2.21.0
                                                rust-x11rb-0.13.2
                                                rust-x11rb-protocol-0.13.2
                                                rust-xcb-1.7.1
                                                rust-xcursor-0.3.11
                                                rust-xim-ctext-0.3.0
                                                rust-xim-parser-0.2.2
                                                rust-xkbcommon-0.8.0
                                                rust-xkeysym-0.2.1
                                                rust-xml-rs-0.8.29
                                                rust-xmlwriter-0.1.0
                                                rust-y4m-0.8.0
                                                rust-yazi-0.2.1
                                                rust-yeslogic-fontconfig-sys-6.0.1
                                                rust-yoke-0.8.3
                                                rust-yoke-derive-0.8.4
                                                rust-zbus-5.19.0
                                                rust-zbus-lockstep-0.5.2
                                                rust-zbus-lockstep-macros-0.5.2
                                                rust-zbus-macros-5.19.0
                                                rust-zbus-names-4.3.5
                                                rust-zbus-xml-5.2.1
                                                rust-zcheapstr-1.1.0
                                                rust-zed-font-kit-0.14.1-zed
                                                rust-zed-scap-0.0.8-zed
                                                rust-zed-xim-0.4.0-zed
                                                rust-zeno-0.3.3
                                                rust-zerocopy-0.8.63
                                                rust-zerocopy-derive-0.8.63
                                                rust-zerofrom-0.1.8
                                                rust-zerofrom-derive-0.1.8
                                                rust-zeroize-1.9.1
                                                rust-zeroize-derive-1.5.0
                                                rust-zerotrie-0.2.5
                                                rust-zerovec-0.11.8
                                                rust-zerovec-derive-0.11.6
                                                rust-zlib-rs-0.6.8
                                                rust-zmij-1.0.23
                                                rust-zune-core-0.5.3
                                                rust-zune-inflate-0.2.54
                                                rust-zune-jpeg-0.5.15
                                                rust-zvariant-5.15.1
                                                rust-zvariant-derive-5.15.1
                                                rust-zvariant-utils-4.2.0))
)