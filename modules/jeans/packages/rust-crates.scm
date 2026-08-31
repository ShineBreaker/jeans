;;; SPDX-FileCopyrightText: 2026 BrokenShine <xchai404@gmail.com>
;;;
;;; SPDX-License-Identifier: GPL-3.0-only

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
                                                rust-zvariant-utils-3.3.0))

                     (nix-ld =>
                              (list rust-byteorder-1.5.0
                                    rust-cc-1.2.39
                                    rust-embedded-io-0.6.1
                                    rust-find-msvc-tools-0.1.2
                                    rust-goblin-0.10.1
                                    rust-hash32-0.3.1
                                    rust-heapless-0.9.1
                                    rust-linux-raw-sys-0.11.0
                                    rust-log-0.4.28
                                    rust-plain-0.2.3
                                    rust-scroll-0.13.0
                                    rust-shlex-1.3.0
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
                                    rust-zmij-1.0.21)))
