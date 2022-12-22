PGDMP         '                z         
   CustomerDB    14.5    14.5     &           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            '           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            (           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            )           1262    17018 
   CustomerDB    DATABASE     i   CREATE DATABASE "CustomerDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Danish_Denmark.1252';
    DROP DATABASE "CustomerDB";
                postgres    false                        3079    17332    pgcrypto 	   EXTENSION     <   CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;
    DROP EXTENSION pgcrypto;
                   false            *           0    0    EXTENSION pgcrypto    COMMENT     <   COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';
                        false    2            ^           1247    17020    mpaa_rating    TYPE     a   CREATE TYPE public.mpaa_rating AS ENUM (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);
    DROP TYPE public.mpaa_rating;
       public          postgres    false            a           1247    17032    year    DOMAIN     k   CREATE DOMAIN public.year AS integer
	CONSTRAINT year_check CHECK (((VALUE >= 1901) AND (VALUE <= 2155)));
    DROP DOMAIN public.year;
       public          postgres    false                       1255    17040 %   last_day(timestamp without time zone)    FUNCTION     �  CREATE FUNCTION public.last_day(timestamp without time zone) RETURNS date
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
  SELECT CASE
    WHEN EXTRACT(MONTH FROM $1) = 12 THEN
      (((EXTRACT(YEAR FROM $1) + 1) operator(pg_catalog.||) '-01-01')::date - INTERVAL '1 day')::date
    ELSE
      ((EXTRACT(YEAR FROM $1) operator(pg_catalog.||) '-' operator(pg_catalog.||) (EXTRACT(MONTH FROM $1) + 1) operator(pg_catalog.||) '-01')::date - INTERVAL '1 day')::date
    END
$_$;
 <   DROP FUNCTION public.last_day(timestamp without time zone);
       public          postgres    false            �            1259    17372    customer    TABLE     �   CREATE TABLE public.customer (
    customer_id uuid NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    email text NOT NULL
);
    DROP TABLE public.customer;
       public         heap    postgres    false            �            1259    17385    history_list    TABLE     �   CREATE TABLE public.history_list (
    customer_id uuid NOT NULL,
    movie_id smallint NOT NULL,
    "timestamp" date NOT NULL
);
     DROP TABLE public.history_list;
       public         heap    postgres    false            �            1259    17390 
   watch_list    TABLE     b   CREATE TABLE public.watch_list (
    customer_id uuid NOT NULL,
    movie_id smallint NOT NULL
);
    DROP TABLE public.watch_list;
       public         heap    postgres    false            !          0    17372    customer 
   TABLE DATA           M   COPY public.customer (customer_id, first_name, last_name, email) FROM stdin;
    public          postgres    false    210   {       "          0    17385    history_list 
   TABLE DATA           J   COPY public.history_list (customer_id, movie_id, "timestamp") FROM stdin;
    public          postgres    false    211   ao       #          0    17390 
   watch_list 
   TABLE DATA           ;   COPY public.watch_list (customer_id, movie_id) FROM stdin;
    public          postgres    false    212   �o       �           2606    17378    customer customer_temp_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_temp_pkey PRIMARY KEY (customer_id);
 E   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_temp_pkey;
       public            postgres    false    210            �           2606    17389    history_list history_list_pkey 
   CONSTRAINT     |   ALTER TABLE ONLY public.history_list
    ADD CONSTRAINT history_list_pkey PRIMARY KEY (customer_id, movie_id, "timestamp");
 H   ALTER TABLE ONLY public.history_list DROP CONSTRAINT history_list_pkey;
       public            postgres    false    211    211    211            �           2606    17394    watch_list watch_list_pkey 
   CONSTRAINT     k   ALTER TABLE ONLY public.watch_list
    ADD CONSTRAINT watch_list_pkey PRIMARY KEY (customer_id, movie_id);
 D   ALTER TABLE ONLY public.watch_list DROP CONSTRAINT watch_list_pkey;
       public            postgres    false    212    212            !      x�|�Ys�F�5���_ ���]��Rkk}*Y���Jf1��Υج_�	$���ٌ����( ��~�o�M��4G�ļ���iUun.+S��j
����S�~��8U^./����i���z���i9����*%�X�,�K�S�a�E���՚X��⩖������WKݿ���m�A�:'�ռ6#�hD���������k<�M��w����˙���U�}Q����~^n�Zf-[�'�]�~�J�������|���כ8�k+1K��Y�j��>�<��J��/��!�R<��㡞��I�gJ�{�W�J?+c�F�he����e%����v_c�x����a���(����pi�Iq^u��W)̥&�r�>�:�T�]����ew�>�ĥP�5�Ux��t���4�l���T�+\�]�~Ňĝ�),�]�Q�]yN�ᛪ�甠�6���*W���z����x���N�_T+i��fi}����E��Ś�rʋ��P�����x�|�..��k���)�9g����:��v��u�N圧���m�3�폧�l�r���{���	�d���st)�zͱ%)��zz��7�RO|�=�%ޤᓪ�j�~v���&�vҪ\�%Ȝ��[<d<���9����҅�S�)+� ��nrn���Y5����L?���������y�F�t:�����)}s�:��[�II:1}��������R����ף�ɦC5Zn24��2��>l�r��&����c<�����.�����y3K��־�f^Aׅ)k2Y9i�OX�SW���٥�K�{i+,R�u�Т���
K���� �˵y�,�������%K|�Zl��y���!�"L�f�6����c<el�Lay���zX�Z�6�A����B/W'�a��i�W������������x����6��{*Q����JϱJ��2}�z���8�ݡo�./��<|V!k0��X���,�iu9h��a�v뽯ӷ�xz��o�)��n�r��Ӱ"k�~~n�u�Z�R�/����XN��+���2�&���ɩ�X<0�1v}����XT4+���_�+����e���>����Q�����`�7״�ڬP���ϻ�TOp���:=��s����J
K�`�V�K�*�����s|Wӑ��W�?�ʗM\^�8|N%^M�U�j4@�k0���uկ9kt>�r���፺�������0�6 	,�
G�B����O��;����͞;��IK�4�z�-���R��ѭs�Jb'5�2���������M�?���aʛ��Qz8ݼO>�b�؝�������VѢ�݂y�{�x=hۿN���<��0�����C�K���4�G���L	��p��y��}ބ�i7~V���h�q���8�	���,�i'p��?^�ԥ�K�{3U,�\��a�����QFjkT��y�r_����L^���Ć���M�u�׶9Ci��g|K���8�a9wc�Y�U.��1���ӕ��V#<P����4��O�x�L�MZΔ�Z^W+��q{�b��0�{��b�Pӿv���
��T��_n��@q������J�U���J�<߲�^
��������>��%�;h�)]Lz�A���%L�,ᚚ(�j����3��C�.��=n\2��ś3+�( ��q�V����Trw�x���k�c����<���f�M�9;A�	�Lɪ�$��ln�	����1b���=��c��
���`p��9�*�k��s���q^��KK���{i�*`�j�dm��k��1M�.��1v��}�t~�	(y�ilEJ�(	�U$�\�?&�2[LǸ�����	_6o��i�]�[�g3�;��p�I���J�4�4}�|D�N�\O����[�/C<&C�X�Y�ű
��60M��h�Y�������t�1��\�0�[+P-��l������T0��f��5��O� P�;�������r�:[37�*��u�
HG�&g��w���|�_W-����~�]WP%1Wh�L >{נ�p2�=8�L?�����wh���tq��ZZCqz���4r;O�;����yK+8}�%δ�K���:7r�G/���栛�p	�\�����O��R7i��.tDٯX)�w�J�(Ak�}u@z��"��+�g,���ICk��5�_���
*���JU|�
/��sb���.S���7i��EK]��M]�Z�=���-e�,�~���ؚ_�ϔ��&qc^a�t'W*"�'KA�$�P������yc"]���ER�$2��&�I]���1���r���L8� n8]��-Ji�ǝ�!8��p`|��Rao�՘V2Z<�����y��*�����
>����7dv+i��<:�#��#h0�޷����Я���!��0� �e�!�<l� LZ}M�Q��ߕ���!��%~EHïd
����ؒ����7I�����Vj�����p�:�����؃�(K4&@���[���~��zzy|�ݤ�<wi��e��Q�@qu2�
5�a��jB���F�>����&�)Sb&����pU�i�A�G�ԢVE`[v��Y�?v_*�������e zM�[��E��CMW�-��+/ˁ/����g���i��k�����1e+�H��������>�_���:8�M������1�Y�I]� Q�,�녱�o���F�%�?C'��~��{ ��k���&�l��u��H39�p�<��ᛛ�s��p9��+�b'4IĚt��o�y����ܯ�{�kPNpmQ��
ot�+�c-2���3T�m�F���r��1i	��2�;��_.X�d@�&��,x��l��C�@.w�U�; X|:��ؓ�2v����+�?�O㺼-�7.��rjz���>���U��b���Z�dZ���g`(����_����8�,KI+�O������5 %��]�uz� [>�z���`�\��vV��X��UQ:a�������⅟�X�˝�ie)�F\kJ7���h�s�l`ܾ�`��l�yJ��P2ı6���Pgi���A�n6�{�ܩ̈�a}ߔ�ta�J5��	<�w���=%l�
%55�%e��8���
?m���B�����g*Z�Cl�-
��f�Y�ci��*�č�������[��ܒ"���Uf|Z���ˎ7�A����6�0�0|B]�s��5�1��f|^�x�X�i7�u<��ry��p��ť����5>^�����%ly$�`J���S��)Nwr �-� �"�b�O��3j[��cv:]X�s����0o�5YE�VcGfrL�+����҅Vebh�T�xq����X�/Qn ��@��O����t+54@3�~<����+�[ߓ��3)}Z�67�o���I�;�'l/ �+���]��?���뾋��M~��� `3�ľY�VD���-T�fԏ���փ~�m���)��`���`.�"xi�	����Rя�u��@����r�~6��v~<E���������}�{B�_��(�����hRq���V��ʸ��q�0sxmX��:��=^n>���wyh�]��0Wm���&S@��=��0}8H��><2ץ�Kc|������t~]��LЉMk+`M����lLܒT .��5�_�
��Bf)g,��@�����5���w������]�.��)�0��KTP�(V�V\f��l�p�0�������k*��T���Օ_S̍j�j |������{~>B߻�<o���l����N�������o%�����y��xfx�e�����L��1��%f���}�fVym����M�O���Ӂ�{li{�a?ɻ�L�V��^�zK��];���ez� oIa���$�v��|��S�F�QV�cT՝�F������:��K|�����"A�w�@7�Åy�j�箇��q=�o�Jڤ;ߴ�@�/HC��lbB3�	;��S� �]k;f ���![w���lsk��mvJ*�i���{p�7~    ��S�傏0�scï؟���Q���3����t�SFӏ񍞎��#����m�f��Ӂ9�;����v� �d⇇���7b�^/�ow�G
ps1��qx����b���u�FMߞ�Η�����M����{$�� �>[<��.�$�&���-%�t,og�2>m�C��ڛ<���Fk�-�MԠ�@ܚ�%_��)���Z]����t�5�6��^X9�
����`�bkj��ɄO�����a�t��|�H��&�GP2��fg�+M�I�	�̪cP�+�_q���S����&8�O7��/�+�̂k'�
�e?�cu��v;{��W`Nxb�fGቹ'͊/Y%0-�͟ ^o�L^v�1�-�u�̾hЁ��]]S,�%x�����W=_����WC��,��J�׫g�^���#��Y+l�Uo-�X��X��&.��8�2a-|�e,A`;zW��Ŭ@�����\�?_+|E��r�0|N�o+AM� 9�`,)ˀ����J`�q��v8�w7�Z7i|ϖ��憙�@�f&�rS���s�vw ��awf .SXZ���zS�ֳ��R��Ċg	�.�̰�2��v�����z�7�X@55W`9�O�F8^Z�	��J�"�	�j#��z���̀H�Nl3�k3�C�����k�(���G�>�o��&/]>-^1$x�Z��W���:lto$4z��ɯ�q_���<��!�����^a���W�Y2��c[cZ-3װ�ׯ�Z/c����U�і��(����.����#kЗ33�ӹˬX8��0�UK���X�%#Vݥ��$��Q4@�����?O������1�1� �K��9j������X���5v㹾<h�~�>�� 2�w2d95�b
�Z,z���=� (�ʊ��8��zb$��%F#�DS�*K@��Ђh�$h�Z��BG �O��ТN�3��&/m��u5��C �]!�3ܤh��H%����a��g.���e���h.� �jh7�I��i�uޮZ��{�0n
[y�ۥ4Dŷ�
F������	Z���#w9L q/�a)Ɂ��^�Np�`k38�f�$̉ȀCX;�{F.��K�B�Y���ŗ;���
λ�9%�#�@Ɛ@��I����=͖��4[��K��+os*rn��a�߳�-̓��D+ϻ�~����%p�{�ќ����礨M�R$a6/_H\��u���@����?�������2 v<mƃ�T���K�Y��p<�]~:O�]X)߿���'T�/{l��4S� ��Lߟ{
��S|%��j�a�6y����u�<�sƞ�O�Ϯ�t�kP~����Mb,dRW��:w��ZXA_�c���,T�:��}������Ւp5�`W�5T��5 �����X%M�8���ϛ3z/�� 3��*��<���ưD �,��
���x<u�v��&ݩ��!2����%sl,��í*�O���G~f8n����i��p_�Ʀ�F�d���d�㤍�f����Ҋ@۱�)0�mĐ�u�.�1�6�� V09I�<}�j,���0��kР�����M¶�9�J��a5g#l)�A0+�9_F��0 _zD�8F !7x�u�%@ǁY�I��.}�e�T$��JRU�@�5^ij����JޒE*f.%�T�kb?}9��Ӈ�yi^/��÷����mh�����
9���w^�_��ُ�q����$�;l_���Z�0������W�K#=�����������)a�Г%<��Ƭ@+`�6U�/�������i��&.�]z3-\�p�5�+h �� (F\}���Hsu ��y�܋b�'���H+06a_�MU4��k�st�-���?��w�����茧[;��؊ؔin�b̀[fK?Y��x���ݖ����k� X�m1r�׹e�زǦ���@���4}٤%Qjc�j�� (cӆ�u����Z�
��E�.����b-o��Y%����~
�mV����������Kay��8Ǧ���Ðe� ������.�^�p+�?��[y�8�e��\���`����-���e5�ڗ��]�Vnm�r��q��(l)gnD2�Z:��S��Vs[ɋ��[�me0a����h�mbF����
k���1�|�|蕇�^����$�#��m��FޢR�d�Tf�y�F����T�����!ֆ�M�g=0wT���1հ�b[P�Ӿ�-u�Ц.0K2ܣ:�thR�5#^jy;��;`�to���|�q�/7�����DICt�/��]а� ��'�I�_{�3��{Y�-�Ӭ�g�쨧~�,�-���xv�ﮇ��K���$��Nxv)���<�'�R��� �h��z�����#��Sf�)�j��"���*�_Ê]��X��f�k�!�w	��^��[e
ळ�dnpf��)3P�����N�m�� ѩ���-�M�"`ii��f�?���Q�Ծ�yH����mf�~9�*(,�/w��oX�nC��������X	�5,i�1�޹��c�)���|�e��df���b	�;
���E��N��h��p�=.a����g1!Gx�Ifq�%��]J'/�˧�t��z��;SX^�0�ױ��`����`��4��z`恹�=p��e�X����{��ޒ��:^�
fj|&�� ������x�Q��,�j`�O��t��jo�����ߜ�e��%vy\?T�������#L5zk��j��][���@�*��pG�Tc�G�[���/�鹭*X��s�5��8e��_i�n��7��'���/ˠ��Y ��έ��կ��Z��6�~�܉UX�)8���4�����RT����/G���⥛��.���n֖�3,�W�CCT�K�M�T�^��d���o��.-�{�Ǖ�2Ź�ȱZ��Pj��	L�+p�^jz:Y�v�E�]GTV�_������R'��'�4J8�g�]x:X��8�M�}��8M�m�̺��� I��nn��"@O�*x�ڟo�V�{<,�.�NL�8SX�{ͽa�
8�#�-� �- �a�?�՛�C�x�aY��Vx�{�p]�
T�V�`�z�Nhwx`B�|���j|�5�Ϊ��R���4>p/�Ń%|C#r���h|̴]���)XV�TI+o�nT��Z�$�t����'a]J]�ql7�=�G�����?�����e�G�[]Ү���k$\p���n������1Dt�(�Z����������K�^N�q�ӱ�`N��&�8|��|���F5�2�0p#}���������
_)�B��Sz�H��芕�X�?�3=�ji��=��P�{ܬ�s���j]�~����rar�^g�n"�֝U^=�kf1h�`���r��X�f�k�k����oN���鸵������˸rh�����5m�>^�Vwe)Q�ҧF��ӻ �9.=�����~���sdA#|(Qa3v|R�c��<�{��_5yNo���vq�;L1Ċd-�N|cU{K
�K���Ƴw��^q��go�w�%~��od�Za�9ͽnZENvl��fz��y�.cGm��wjQ���P.3#S��Y��*T�mXO��2<�z��s<w��$^60�(^�J@G �y��Y| ��#>���i��š����d�1ék�����UYdt,�P���i�|I���x,rT��^�@�m,�s�������9���re�$h�3LJ�G���拨�`���5��j�G����p�׈w������z���sfAU:��Zc�&��V|��Z)����N��հ�G��J�ļ�adi ϰ�����f<�w䅗ǥݤ!Y��#|J��Ƴ�ْ���|�>�]�]/{��K�ʻ���G�%u .=�E���f�j������î25���Һ0�i5R@c����,X���sQ��J�nO�8}�B�O�>�}\��Y��!��d�+�k�U��Xf���O���xc��Q5���XP6�F������r��ue�>�Ϋ��4����+�^`�̈́�~    �{�p�X����"�=�+\��`�a�~׻舾�گ;�z�f�	$DF�+���W��Z�Ȯ�����ov_(-_6i/7�C � ��5
�Nh���[�%/����{p�?��_��/�U���j�将Y�G^�8-AB��*Y�+�r_k/���n¸Q��3o�>0��3�����������i�^�!�P�y{�W�	�D�g|�u�-%p�����\�68r�5�ٷ������ ��,���j�� R�Dǉ��&YY��Y���e\i� �,���;�$�f^�k�������������
C[�;��7ET���3�5NE�'X���,�}x	�Hd_���ܣ˱�<dF��F|~QV�OeB�����t|<0��y��a�|�a�jX�
c/[��w}�K�٩��	Օ[ww�>������$
C+ t��	�aWz|�#��g�o���%2��k}�6iy�4��gWp=��0"X�����%�`,��k�?�ΏǗ�����.�y')�I`[њ�ǚ��c٬i�t��; ���o���噗��Y��*���ϗ�Ě� [��
*g�-y�+a�__��Yr��/�k�ș��'�Z�-�Z ���]	����[K�-d�ƺ/Lt,�\+�I�cK;p#�5�h_�ѭ�W��?�W� 8;�:�X�\���lź[ 1�����[��x8W��nQ��.q#V�0��Ľ�~��L6et���D�?�݆�����>|��
~�Ȕs�l�-�h)��Xb|R����׌�}�U� #����Q�'�AL��oh�b��m�@����n��إqvn��n��g����>(�>6�-鿀��9��˾��:E�30�l�	R�$�6��hWp {�'���z�=ɛ��߽*E�]a��X���A�01�=���9q�C�(X�C�����7yx_*���4��)4+繄�mX��Y��8巇�[%R���4��J]+$c��6�J��h�}��%��>��ͳ�C��|Ԭ��m��1�7�V�\u
�i�ӎ�'���"��@3���b����V��a���,.����t���]aE�&.'�C�{�#�I����r�Ϋ
�gY���f�XƵ�L��ns����*q���d�������qKff����>[*o�Ү��K���r׫�s�M�dI	Zb.�w|���u~d[��"�!��*B�"hvN��,$����0*��wl%}��K�c�SW]����L)�,I��I0���`u���n�(��0���4F�D�AE�=R�2��֭�y\�2'%��9�@f]�M:��^
�p�vvƲ��υ���Z'<(��6���
��W��y��wi�e���Ps,���U
6��i�&��ޜ�_u���n�^)�Q9V\3��~�u�̢��R�dIPcuͮ�@�z��#�{�&�	㘚���؀9��g�������}����<iz�")#�q~^G��,�n_�%�ZY*��i���RR�a9��N��'^-<LYk#�e�|/���%田؜`�G��������3��d%gY�z�E�ug�_I����� +���������	K��A3��		5���K�s���c��q8�C9�Y�	r��.w����+z��4g,{)5
S]�����ȡd�]���l�:'�.��������a4��6o�y��Wr�|����ƛZMI���[u{��M�Q h �g���#!c��u�y �Ҳj��zV�j�^ACj`q������å��!�j9Z�w�����nF��� �� ��xC��Wܯ�]���c�<��&��:EQ�*Jt=w�1mk��dR����+���*4�X�yi��i+U![g�o=�ћg{�oޤ1� /p9�0��#�&A��"�)���;�b<�zʔ�ж'kLsaꍑ�ީ�����3��6,�!wlWz�w-���[� g�\4��ny��d��Lu�c�@�xHH,7�4|�M���2DvRx,�@DVY�[�4����������&�w���t�L�*ڄ7�)\X9H*����3���>���K��q��4<-\2��m��3�&�J>ߦ_8���ډ�pdc�V�|��k�}>�=H�\e�A:���1�6��C"��߼-_�8��Uj���m+� c��$��������Ne*�zIo�Q����Y��=jW��٠m��\�5�<��A����b�y����W����1pڄ�3$��8�r��ڏǗ�2}�]z��12h"��%���gW} '8���V紐�d�s�~��xx����(�ҁ��-��?�z\,*��Ԏ;�-����r/��LA��n��C�ؙ#��lh���I�籝��4�0�E�>�e֑�,{L�e� yB�V�+�z�R�����2��&l۪g�VC�G����#z��zO��r��!W��m��D�N۔^#]�I�e$n�+�RՃ���vU݋����������Ep�\���T��c��/5>N���؏�q��z�8��;�IX昽��ՄO��d���k܃H�r9�r��"8\e�ў�u!� �p ���#���S�"]�&���%��G��1����Tw6Y`��r���E�q���Z��wq�Cb	�Wm �e/;9.`�tD�L����n���g�B\>�����E�L�&9���V�fu�)��aC0u� �L�F�Y@c��-+�LLxy�܎�֎�+z^��M�����.���˸�u�k�^�&���5XaaX~�en9)���X�``�:!,�7a��]��9:��14�>��14&-`���=����=�v/*�t����k�!YX��g9���C��%>x��%�tq9o�
J U��?P�,/@lxp��]� ��p�j�.r��q5@���f΢ℰ�j5�n W�`_a@��N��(!,�.�0���lee��(�(1�@��ƈ����o=)�����܅1��Tn5N�f�>�H�VE�+8l�u+w�t��{�M\�]�V9�e�[u�>H��.4�h���x��pd��x��Hi��] �`u�d�ʂ��h�LR���My�~>�`&���M�!�Mު��uW&�0.fYs(���՛�~��CN_z�֞�Ct�+�������o8I����k�~�>�����a�L^�z��L�yS�Egkl-���y�$*�Y�=ߞ��aJ]`�n��<V@T���\�8��6�Hx�b:G��m�nO�}�?lsu���L����x��0sr��ڒr	�����FOF�������	��ː�8�L�+Ϫ�+��5�`��r��/�p����Pͪ�
ߊ�|�06(A�9��C��K"VNn�7i��	��(�p�iO�3a7�?�(NL�mN�d�V��]���Qla猧56�8��z_����{�Xn��Z��c��+�1�mV2��9��]d�C�	�B�������3�܅�&�����u�������(NR#��5lZ�>�^Kw�ל&<��>K�Z���x>˙"�	<�HEn=�;��z�:Hw˩KC_��\�N���G��ܼ�Y�T�
u5��mZ�ǭ����Z�0Ԟ�];a14�%x)��f��QIk��M?���_��'&���<�p��h�f�8�0�g�r5
O+�<������4}+��m��"�^)�M�$������@��
����}�����z `��3�������<f�H�@�`���XX�����ϓ��-I������:�PZ�p�Wj�EN��YO��X}�����h'[�Roc4`�����U��x@��.�x�[�����nib�)�CkI8�.ev��}��t^8"Q��n����h����e����퇱��QK	\��!eb����j���ޝ�S[���y��t0��/��q�9�@�s�V�i�j�O$�x�=���)r���Wu%�� ���H|���A���o��vc���>x�|����=3�O��ϔ�,��l��QÂ�jd��� ��o�C@=��LQ'���Yηm��\A]Q"��
�w�n�f�/    ǵWĺ �I\M�Dax�+00��C~���?v��JZ2ϧ�t��Q�@38��F�@��	pYB)�Q�.�_��vB���;�Dg�gsZ"ϟ��64 ��L��=?����g�ti�wi�O��IX7�d��2�6kz�+�[�',��#L�az��塋���c�{�K���0`�v���画5h��2��g����:f+t�=8iz%�ȱ~�*��$���6[w���6Zw3�C�gm\9uE�>a��#V��JCG�z��7���#�ow,�T�i2�YD����dB��
$Y�8Kn[����v���vi�w��4��ONQ�Z�84�����6��q��4�Md	ġEr� �6�YB���;���	�o#� �����'J���Nԛ�1���^���*  Q��/͠�V�p�<ˈ���wy����IXc��s`=��&��+e�{�7�-��;�? 4@ɳc��1�L����/�YŔ�ͼM���Sk"�x�,PT���E�#�upq~�5�=��l>���	K����sp�1w�YQ̧t-x��2%��-n���]�
Ӈ���.��λr�nP9$�(�x �ˁ�ϱ9�>�eOq����jg�V��Ș|c��Ҭ�#)�� n��'����;��Xם̙3\�Tv�BI�����孔�]7��m���n�8�K�F�9�^�Ϯ�GXgp��v.AG�E�z��-�EI���	���� N��`r�'���3��=63�ڀ���&=�x��X��}��c3�i`c�Mf����>�c�wq�;� ޶`�9��	F�?1@.wS�߯��M�|]^(����@Y2��'[�Z�,�<���p������q�jq�~���2��hX�RgUg���s�{�y8�߱�_����-ڀ���!#���#g��0�<>'�N��
��k�\��~͉6�Nh�����^A0�VhA��p(��� O6��?m���{����nz�!-�� x��F�y��+h��\�����z��%/�c�C����H	��gc��55@�[�z��ɻn�m`��*i�a�I�V!�LX�Yv|�9��`����[}=��C���8ĴNr}���㆑�{Ҁ-[Qc���U�Lg���:w&��Ln.����`�9�-���ʯBU�3���}�������K�l�+I1�*+�w@�`��{��¾�����Sl�-�Ǩmj=�����c���FmRl�Vd����0�q��Ù��1Y���h������j���}������I&u�x/���ʶ1���V�XM��ʛKjF�*x����陮��>��^�˹��m�$gÄ!�R@�k)�+������9]I� �w�ı׳���rN9�wc񐸵��rkۈ�S�c�f���Կzh_\i���9<'�G�i���:Vz��ͺ�����c�fݤ�����(�8y>���L�̜eTM}f 5�cXsg�u��<-Ds^�,���^�����+�����^��4^�+�����������}W� ��7'�~��U}�p���.}hl�;pO�I�X+�y;�m:6[�^�x!���LG�쁁��G�ѿ�nײp����Gݍ[aZ�Ȭ2�s�eڿ=�I{���a��m�Ax��6dJ��,R�����-q��h�o��xؤql�F�<V]�S�0P�
؜c�I�[�>��._o��,ջ�g|zx!ҢD��J�x*��ײ��(d�s�@��x�*�qn������DD�8�CEeRM|>�ƞ�+�;�ˎ�숅D#
i虚k�Z�P����dh�X�-��IH<�{u6�1�Mo��ϛ8�&�LaS���YϦ��@F��5�m�#�_x�ϕ�{����&�ɭ &��:�x���Dx���J J Q���pq�36�IwXwʠJ��G�p&O��[}?�*��9��6G��C�E��_���o���8W�~h?1H�+��c���� Y.r:n�Aީ�i��/
V�cd�g��8���9w0k�n2�;�dm��ǳ@��~nJ���BI�{�M�`�W�DC"{�
�}�I4�4Ƨ�!���&�L`E�^ �ٮVfn�G=rdE�G���x?e�yuނp{VMkaG+K�M��&���)�я�c~�xL#�J@Ɣ�T�=�;�,��8s��$��J`C�ᤆ����9 &���gR����W�E�H�����ţq��jaR�x���@�gNH���4�)�*��@�H���ʖ�W
˥��9�f�P�ի~&>��f��Qv������㵷��d�.��~��:�{�B�[٦��"lq%���T_aDzd	��&9�*b����&F�<Gዕ�S�۴����ۨ�������� �*8I��R�o�ך�>�AO�X��E����"+J��:�+��f�������\?����!�ʶ6�*v�z��Z�&��L�lf/A��>��V��IC��x�)���u��N�P*���,�	���a.?Y�z���\8��r�Û�p,�Ō6�9
�Oa_Kf���:}}`y���K}a7|�?,���1�Ob%X��6� �j�]��N�}F��xf���#�4wy�7y����ϲ�AjF�xZe���0�:z���8m���&�/�t��V�U����j�9\�6M�4iWQ�~�z.|��Y�ڳ� 7q��E��s��@�-`����H�]����FO���[���{��b3����s�"S(l�l�ij�;��weZe�^��L���"�qG��|+#�,����z���r\z��e�]��x��g1���4�QD`l��o�ϓ�A/������)x}�ܸbӖR;wY��+ڳ;���x�Zj��X
��.�˝�\&b�c�9k�s|p�v�}��5��{ȍ����#7y�A���G���d�I4������a=z/D`���G��i�Ut���(-O��$9��`���$������w��'\��'Gr�A!}bn!��p	p�x0��s���x�W��.����k&jN%�xw�i�2<�_u��
;��9.8�DX�;ӂ��c�j�<����2��s�o��zXb��-$p��<�k�ee��l����a�8v��F�g�es�G�����K��ܥq]\�g`٣c�������$)!��L�2�e�U��,�.m��7rd؊�C1'-�/�P��Cϡ�x4����3�7�M�2��Q�Ԙ2�Z���4�>�Ѷ��3^�������� Ϗ��_AO#�`��a�YA ���++�x=��{��9|���t��S���C�j ���;+�9�68����;N���Č��¸�RzXo�F��Q�=��eщ�Z������� �,�\vwXe
x��+�Y`:ct����M����bͲ5�����Mjf�nr���٭�B����9�<6�����_c�Q�]����t�li��M�$G���N�:1�B��?���{���x�Z������(��3�3�|]y�n�u���a�=�px��j�i�Q�n'���G�9�]0�̺����O�t|x`���3	��2�aU;��ل�8�����K��=j^��B@$h�q�~��*��.��Q���m�]�i�<�~�.kR@`��~�3�o<[n���4�,j#V"�'U��� �2{jRT�5�߱4�x��]kP�}]N7i�
`�F�{���T�j�����@�W�n.蹋}�������D͹zv�� ;�V����r�C�PP{�㩋�l�^�#�ƌ�A=:�#��g:-
,���iy/���	�k+�^v�1�nxyZ���"�C�@��k���#��xp���]dr�t���"�#k�$0�f�:X=������������y�����ǂ^��<�+Mc�@�?���,@�5}����S{Q>s�ouȍBd���.3NF��0+�Yd������.�؜/�Ů�P�.ђ�� d�%�9�@����-MTN�ܺ����!�[xX^��N�OfA{b�^R�_%���΂��z��s.~� ��M\^�"xo�l]k��h絲���he�a�A�����ĭ�S��T
Cͫ6    ,tϙ���YAf8A���
�'l�	��P/���DzKt�IMf��t3�pd�cT��O��7a�+�nጘ�L�v��]b����m=؜��1�c��Q������1��1��X2���,Drl���q�씨}�������j�=G��gr���b�f@����i*�s��O��{�X�YJ����sm+{�e��آ��i`�=C2,�f��c�{�&��!�jMaGc/��c����h�t���k��z�����	�r�IC/,b�k̸�nl�8�n����v�6T���y;\:y�4���7��bL�����6��u׿���z�l��c|����&,�ҕ�OD,��"K���Yup��Y����ϔY���Ý�����k���g��L0Q��Y�Z61��ϧ+�F���<uq�/�`�dƤs��$��������c|��l�?��D����ݽS���<��c�W@��g�V�Jh����><^{����u\���>�eJ���c�9��d�.�=�Y�w�G���K{����Xg�܁���rF00�YrSު�v}��k�v}��PC�j�k�}�n����	b-�9��5?�"1�{��jyV��Cb���|�1q��%UKTx��&��3�=��r��p���R�|���v�SL<���p������c� �KR/F}z��%c��g}5��e�Q�Y<f�j�7/R��8�1u���sa�ߛ0\������`�|N7������>���[�>sV�i���&�\""�}���g96�疛��!��wy�g�r�R�<�)����&�+�BvE��mqɠm�����������yJ��/K�~��3�f��l���|�q��ޭk61�)�D���\i�x��x�4h)���#N�$���ٱf[h �ֶ	�<ɜx�y��8� �Ȳ���x ���g�h~8{�9���]D[��
���>D���>��YF��3��4�,�\�_���Ӯ���{�/��Oc�
��f�Y��b������6�zb4����=�p���Mޕ����yb���[��M���7v�&�og�����t�;�, 5�	�'���(W �a� �R��=ߟ�e��ԥV���0 =k�8'9�	�3:X��X����p܎w�ɜxpgj�Z�u�P�^ڰ۶�Y��un���ș>TΜ�	|�������xn�$Ҫ����Q-���L�O߰8�8),��+۠ ���|8�;@ag���.:�3�A�X � ��X7>G�M���)N�O�v��lVP�~*c8�52x���0� ԍU�1/��*�8�¥���V��̞.f%�l麓��E�Ȳ:�XUY{q3���k�	�L�+�#G���(�K���mS�	D����*5�	��4�>@URA�n�Xw���c����Y��6b]�f�2{�K�}�ʭ�%;�Yc�|;���|���Ԗ��:̩O�,�g�a]4�q�X�?��$��*ۙNہ���<��	�����T��ؐ���[��d�p���r��/������)�+���ŽJ`6�|��=�p���Z�=/���q���\`�eU�f˓du79��|I�Qg�������H�y�GSR�$i��[�!�8�x�ȕ5����e�{�v��wrc"7eg�y�nf�d���e�CE��]=�'���T���x���.��_l����q_��y����7�f�c����&�P59��ٿ�$�j�DXj_��<�{x���G~P�n��a�ڳ`4VK'���D+�Y`�V�3���1�m嘐x�՝��c��c?_��~R��5���d�u�g�B�>��h�J��������[�$F��f/�k�������{�- `���B�w	��8/� �b9~�����1�$����I�|KQ@�d����1����*���D��$Y�	�wz�\eC��͵��i�躱�1r p࡫Ĭ���د�W�h-�P.�Gw�K������2�S\�*�o���P�C��إ�=��k�Г>��|���Xa���6r�S�Rk�5���πƙ<Y�ˮ�w�K��V�V-o+�{���V[C|���,[e>6ʁF[m!+{���ñ����N�On�w�P�+(g�;NU�E g��S e�O[%��0��=��q������`���v�)^�cB��~��ԑ��r`'E"�.�іJ�K_�'�qb�\E�� k�B�Κ? ���Zi�:iN�<��Y<c�v�#�X ��
Ag�\�ϰ�~�~��n�#-x�8�AWV�߮�փYA!L�d�WV����=�����j���j9C��v��W��"p+������nV���|������M�r� g�)w�'l���Kŉ%�Z������Ӕ),�]�1��Z9���b����*ͩ��00J����~!d~��ϗ;lA[\�>��h8k��<:���!��}�&OE�!�4ϛ����->�؝܍�<�Gz���	�Wm�(�na�T��)�W9Qy��pR��6�����{�ǃkv�fyk�8N����z�˗a�Ep�e���=9��ͼ���RŲ!�%��!Ҏ�(,�.�kߒH,�Μˡ`+W��o��Y�����js{�{�Ļ��S��i�S4%)b�iZ���R�d�X�^��q���K����F$@�#�&s��'�Y{d� MT~�=�[�m��L��~F���`m
|���)m2�YY<,2�3l����s�e#hc1��.�k�,�Y��3g�n5��-}��g6_[c�Y�W�	C/)$. >�٘]�%�����/ԟ󩷵��F�$��9ZRn��$��xV��Z쎀X*�G.��'lo����'
C����e�>��E`uJ�%�3���pt���r��O��@�W�\`���zV�)��bjRU���r� 6�1^n��!)-\�/���U��̜�Z� Y|]W�.��mګ��֭�9{u\}�mM�=���L M���,K�����^x���9��(Q�[
~e�YbU���ڐ�k�\ߧ�~���~G���8��y@p�[��@֘X7�ĬvyZGTNY	�)���&`��ل�ʀ#����8�p��H3�4�Zҧ�����>��p�r��c_�=�u�η�gYjV���|;?l_��w=�w���S���')�N�ܶ�5"G@���,h{��5aa>�������A����N�����,� �X���Us�χ>*~��'[%��w�8�k6+�K�yO}z�E��.�m��T�z��0�㞇rQb%��&y<����U&�K��Di�O��-��&�^�|x�$�}P�i�}�5+��Ř�Zϖ��H�3p�J|��J9ua��N��6%$t����(��%���{?k�S�E���f�]F��-����X��Ĕ���%c�e��/�ā"���J��D�sZN��b��z�%x��cS�����\ߏ��m�c9 ����$2����y�4�_l���ea���}���$� �׼����NN԰T�����b�>�X���/g�}O��~T��/��d�Y�����<��|��Y�5� �yC��F�yn��(R��a*s�R�s� ą���Y[`��0_\�nϜ>�J������Y�S��,:��N�T�I�ZqkS!.���,�����qU  `䐤�1l���q���΅�=��ϊ |}?�fq��Ԣ�!���^��Wl����p�r�ź��lݵ�)�+Q�j��{p�6z�,7b��Ԯ2}����X�ʫ�pO��n#r8do��Q1���вj�=��4i��e�9�{��ɬ������Y3��W��P {�ˎy�=���2�n��^Uv�t+�uß� l�ͭ�p	2?f	B4c��e\3��z �c���<&s2#�}���»�R�s���ל�K�T�9����~]^�ׯC�\�V����@ձ=gl��
u=����T��La9S~���V@1Bs����r�/[��]ꮽ^�c�R{W%��K�l��.�wm����{��9ך�c���y��?wD�z�<��^)W,�,+�9h.<{oዦ���� �  ���Gf�����iǙ��
M�2<ٳ�<����Ɩ(��Ӝ~����<�z�;s*�kw-Ąc1p����&%�[����o,�d	\���z��7�����	������N����Y��~�z|�F�W�8�4� �<�U{��`�u9Unձ�:99�	��UJew�Ji���cVU�.��M��Z7��s�Oo���Gp�v�q�78�<Δ�Z �j9=���"1�X��9'��������V��_�N[)*6;��=ޕ�	;(&�����0�r���Q��9����]�Ӥ�l#�f3��XX��hdE�5���Y9p�@D��r�)��4�h�I�0
�fSY:	[ku��D��zx�@���ީ��=G���ѣI�s悙y7Ӱ+���"�������R�w��!�$9s�X���8 �q�-�D�����+�]O�`��������.����Yc�{��& �J�ɐ�*�_��B�=��7qI]b��dR����<r(��)��*��I�x;^�3]j�4����s�mɢ��/���n�Ic:H�$@��l�UE[=I��?�%c6Ԏ��i�,�=�u�W��>8�X6K�R�<L�H�%�3�jq&x��T�P��3��tq�4?�Kl���׃�H��-i��)�;�_��8R�fl�2��kI�l$mzX�M�]n~���ɏ���]1��Tj(/�\]M�k�E�M�ަgQR�;:���3ct��
����`پ��f����)"�ㆤ�{~3妅�t��<�
�7�k6�D�re6�盽�Λ�O� o�b4��	Rb7#�>2wp�����.�P���>���3��C�A��n�l3[�=\}��݉���=�7sߓ�h�Y����j��AGAOz4-����є*�����N�L���@F�)��v�������|�(���p����m�����A�4z���zf"3�>���n�he��ŧ��kb�V�O�N�M.ٺ�a�c� 1�3�]u@��bi�"����Nm��O��~�"�:f�2q��>�������+s&/�}����+S&f�W���'�6-cJ
(����ص�a4����nγ��I@=߹�����,�÷1yј��۩����~ǩ}�t>��e����^�h��g�g {BJ��6]r�BA����_����_۟�;�H�X&P��;��ZgЃz~]wM��fo�/�:�*�IܓY�>�ā���r��:g�N��5w�Wm��1]{��٫+����3C;�W��YkU��w=d�
[sD�"sx5s�`�z^����$�_�<�Tֵ­���fc4���cYHL@h�k�P�;�T�Y���8D�M���	��(d�B���)�b;��o'֫J��� �L0\Ú��wJSh���m�7C郩��b�ڗVߗ�.�in7ٓyP�L����:�)`ҧ��l�l�@��Ux;��=�����@^{k��0�^��D���
`cB����;äX���y�t�ِ����!ǐ��}��:_������g���Q�sS�0�6��	��mΩ]Z
���s~�ٞ|��,�w�����'Xu�g#�G�Y���Ɓ�R�e��K�Ѻϴ����X�>N7FyD��P�(�u�5�����Q�.t���b��!��7����[5��l�4wL�P
L���� }�y]�F�l�-�h�J&���zi�ͭ��T�I������b���K��	N��_�tF&O�k���:�>o,0'8��Կ������ιv���jP
�r"���,?��<��V2��$��t�7qp���ߎ�Zјd�8{pB&6V��q����R��g\��Z}�S�9�7�DV�Z��1��]3�e�"�G�.��2������W9.Mm���P�\�� é��R�mg�K`��%_̦g��;��EQ�� e+���j��9H�X�ѯj�Hys/�nì9�X͋�og�V�8d=�����`�׎��y}��M�4��ɳ3s�Sˆ2T{���xW}�(�����ί�k{*�z����D)�5=<�Ư�{t��M\B�o쓷H�;��&'W��\�1S��m2Y�6�^��w�z:q�}���bo�^�X��t���׊�J���IX_�"<��!S�Ǔ�h���b�G3M-wŬ�7�hƣ.��J}웘�=^�0?�=�1�m��G(aD&����'C{n��c��hICzF�@G�%�3wKb�r&����l���}?D�ک�{w~�����%�l�����+=�錪^�cN�(�`Pc��z�G.���#U1c�x.��oN��L=�ቧ�����s������M�I��_v����^�]5�Ä�Sfovt��Y~;�L�!Dg�V��+�}u�Y�k^�����>Y��eTd�w?M��I��H��o/�<Q���^n�< �tT��pf���Q��O���;�T�ޝ�2��X]�Ou��or$�D��]�Q��-�U�l���(^��ޝP�ݢ@����GEG-&�Yk'�,?�X:��՗?O���=����c���9�:G�k�C���+S!�����L�(�jG�&&����5��g��.��6�Шp�O�R�\�9����]&{E��s�+W�sF�Q�JQ��;m~��KW�ċ���� �U(�f�z�F?�v<P� �0/}$J��mU>ԸΊ���I���fna|[� �!�Ĉ���u���5�g�;�E��H�e@�~g��3��Û��,���F~��p���Eт��"�#]���,���.3�bm��I�F'̐��dY`�A	1�g84�[��/|OT����
g�۩սJ�G�t��&i��0���Yw|4������c�r9A��N��H7	���ޢ7S
z���K���&�m����OV�*N���56!���?�zI�d�� /��s�c�����U������Ԙ����^�aR�h�x=o��ҵ9���#���JCb,����	�ژ@`ff�!Q�&Ȍ,�n���"����6^��A&����}���� �^L�      "   <   x���� �7���D{� �_��~_�>6<+���S�0�_L��]�d%tA��0��P�      #   5   x�3�05711K�5ILM�5120ӵL5O�MJ4H3O22L6HI�46������ Z
�     