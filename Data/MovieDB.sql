PGDMP     (    '                z            MovieDB    14.5    14.5 K    ^           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                      false            _           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                      false            `           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                      false            a           1262    17497    MovieDB    DATABASE     f   CREATE DATABASE "MovieDB" WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'Danish_Denmark.1252';
    DROP DATABASE "MovieDB";
                postgres    false            S           1247    17499    mpaa_rating    TYPE     a   CREATE TYPE public.mpaa_rating AS ENUM (
    'G',
    'PG',
    'PG-13',
    'R',
    'NC-17'
);
    DROP TYPE public.mpaa_rating;
       public          postgres    false            V           1247    17510    year    DOMAIN     k   CREATE DOMAIN public.year AS integer
	CONSTRAINT year_check CHECK (((VALUE >= 1901) AND (VALUE <= 2155)));
    DROP DOMAIN public.year;
       public          postgres    false            �            1255    17512    _group_concat(text, text)    FUNCTION     �   CREATE FUNCTION public._group_concat(text, text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $_$
SELECT CASE
  WHEN $2 IS NULL THEN $1
  WHEN $1 IS NULL THEN $2
  ELSE $1 || ', ' || $2
END
$_$;
 0   DROP FUNCTION public._group_concat(text, text);
       public          postgres    false            �            1255    17513    film_in_stock(integer, integer)    FUNCTION     $  CREATE FUNCTION public.film_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer) RETURNS SETOF integer
    LANGUAGE sql
    AS $_$
     SELECT inventory_id
     FROM inventory
     WHERE film_id = $1
     AND store_id = $2
     AND inventory_in_stock(inventory_id);
$_$;
 e   DROP FUNCTION public.film_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer);
       public          postgres    false            �            1255    17514 #   film_not_in_stock(integer, integer)    FUNCTION     '  CREATE FUNCTION public.film_not_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer) RETURNS SETOF integer
    LANGUAGE sql
    AS $_$
    SELECT inventory_id
    FROM inventory
    WHERE film_id = $1
    AND store_id = $2
    AND NOT inventory_in_stock(inventory_id);
$_$;
 i   DROP FUNCTION public.film_not_in_stock(p_film_id integer, p_store_id integer, OUT p_film_count integer);
       public          postgres    false            �            1255    17515 :   get_customer_balance(integer, timestamp without time zone)    FUNCTION       CREATE FUNCTION public.get_customer_balance(p_customer_id integer, p_effective_date timestamp without time zone) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
       --#OK, WE NEED TO CALCULATE THE CURRENT BALANCE GIVEN A CUSTOMER_ID AND A DATE
       --#THAT WE WANT THE BALANCE TO BE EFFECTIVE FOR. THE BALANCE IS:
       --#   1) RENTAL FEES FOR ALL PREVIOUS RENTALS
       --#   2) ONE DOLLAR FOR EVERY DAY THE PREVIOUS RENTALS ARE OVERDUE
       --#   3) IF A FILM IS MORE THAN RENTAL_DURATION * 2 OVERDUE, CHARGE THE REPLACEMENT_COST
       --#   4) SUBTRACT ALL PAYMENTS MADE BEFORE THE DATE SPECIFIED
DECLARE
    v_rentfees DECIMAL(5,2); --#FEES PAID TO RENT THE VIDEOS INITIALLY
    v_overfees INTEGER;      --#LATE FEES FOR PRIOR RENTALS
    v_payments DECIMAL(5,2); --#SUM OF PAYMENTS MADE PREVIOUSLY
BEGIN
    SELECT COALESCE(SUM(film.rental_rate),0) INTO v_rentfees
    FROM film, inventory, rental
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(IF((rental.return_date - rental.rental_date) > (film.rental_duration * '1 day'::interval),
        ((rental.return_date - rental.rental_date) - (film.rental_duration * '1 day'::interval)),0)),0) INTO v_overfees
    FROM rental, inventory, film
    WHERE film.film_id = inventory.film_id
      AND inventory.inventory_id = rental.inventory_id
      AND rental.rental_date <= p_effective_date
      AND rental.customer_id = p_customer_id;

    SELECT COALESCE(SUM(payment.amount),0) INTO v_payments
    FROM payment
    WHERE payment.payment_date <= p_effective_date
    AND payment.customer_id = p_customer_id;

    RETURN v_rentfees + v_overfees - v_payments;
END
$$;
 p   DROP FUNCTION public.get_customer_balance(p_customer_id integer, p_effective_date timestamp without time zone);
       public          postgres    false            �            1255    17516 #   inventory_held_by_customer(integer)    FUNCTION     ;  CREATE FUNCTION public.inventory_held_by_customer(p_inventory_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_customer_id INTEGER;
BEGIN

  SELECT customer_id INTO v_customer_id
  FROM rental
  WHERE return_date IS NULL
  AND inventory_id = p_inventory_id;

  RETURN v_customer_id;
END $$;
 I   DROP FUNCTION public.inventory_held_by_customer(p_inventory_id integer);
       public          postgres    false            �            1255    17517    inventory_in_stock(integer)    FUNCTION     �  CREATE FUNCTION public.inventory_in_stock(p_inventory_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rentals INTEGER;
    v_out     INTEGER;
BEGIN
    -- AN ITEM IS IN-STOCK IF THERE ARE EITHER NO ROWS IN THE rental TABLE
    -- FOR THE ITEM OR ALL ROWS HAVE return_date POPULATED

    SELECT count(*) INTO v_rentals
    FROM rental
    WHERE inventory_id = p_inventory_id;

    IF v_rentals = 0 THEN
      RETURN TRUE;
    END IF;

    SELECT COUNT(rental_id) INTO v_out
    FROM inventory LEFT JOIN rental USING(inventory_id)
    WHERE inventory.inventory_id = p_inventory_id
    AND rental.return_date IS NULL;

    IF v_out > 0 THEN
      RETURN FALSE;
    ELSE
      RETURN TRUE;
    END IF;
END $$;
 A   DROP FUNCTION public.inventory_in_stock(p_inventory_id integer);
       public          postgres    false            �            1255    17518 %   last_day(timestamp without time zone)    FUNCTION     �  CREATE FUNCTION public.last_day(timestamp without time zone) RETURNS date
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
       public          postgres    false            y           1255    17519    group_concat(text) 	   AGGREGATE     c   CREATE AGGREGATE public.group_concat(text) (
    SFUNC = public._group_concat,
    STYPE = text
);
 *   DROP AGGREGATE public.group_concat(text);
       public          postgres    false    232            �            1259    17520    actor_actor_id_seq    SEQUENCE     {   CREATE SEQUENCE public.actor_actor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.actor_actor_id_seq;
       public          postgres    false            �            1259    17521    actor    TABLE     �   CREATE TABLE public.actor (
    actor_id integer DEFAULT nextval('public.actor_actor_id_seq'::regclass) NOT NULL,
    first_name character varying(45) NOT NULL,
    last_name character varying(45) NOT NULL
);
    DROP TABLE public.actor;
       public         heap    postgres    false    209            �            1259    17525    category_category_id_seq    SEQUENCE     �   CREATE SEQUENCE public.category_category_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.category_category_id_seq;
       public          postgres    false            �            1259    17526    category    TABLE     �   CREATE TABLE public.category (
    category_id integer DEFAULT nextval('public.category_category_id_seq'::regclass) NOT NULL,
    name character varying(25) NOT NULL
);
    DROP TABLE public.category;
       public         heap    postgres    false    211            �            1259    17530    film_film_id_seq    SEQUENCE     y   CREATE SEQUENCE public.film_film_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.film_film_id_seq;
       public          postgres    false            �            1259    17531    movie    TABLE     �  CREATE TABLE public.movie (
    movie_id integer DEFAULT nextval('public.film_film_id_seq'::regclass) NOT NULL,
    title character varying(255) NOT NULL,
    description text,
    release_year public.year,
    language_id smallint NOT NULL,
    rental_rate numeric(4,2) DEFAULT 4.99 NOT NULL,
    duration smallint,
    rating public.mpaa_rating DEFAULT 'G'::public.mpaa_rating,
    price_id smallint
);
    DROP TABLE public.movie;
       public         heap    postgres    false    213    851    851    854            �            1259    17539    movie_actor    TABLE     d   CREATE TABLE public.movie_actor (
    actor_id smallint NOT NULL,
    movie_id smallint NOT NULL
);
    DROP TABLE public.movie_actor;
       public         heap    postgres    false            �            1259    17542    movie_category    TABLE     j   CREATE TABLE public.movie_category (
    movie_id smallint NOT NULL,
    category_id smallint NOT NULL
);
 "   DROP TABLE public.movie_category;
       public         heap    postgres    false            �            1259    17545 
   actor_info    VIEW     C  CREATE VIEW public.actor_info AS
 SELECT a.actor_id,
    a.first_name,
    a.last_name,
    public.group_concat(DISTINCT (((c.name)::text || ': '::text) || ( SELECT public.group_concat((f.title)::text) AS group_concat
           FROM ((public.movie f
             JOIN public.movie_category fc_1 ON ((f.movie_id = fc_1.movie_id)))
             JOIN public.movie_actor fa_1 ON ((f.movie_id = fa_1.movie_id)))
          WHERE ((fc_1.category_id = c.category_id) AND (fa_1.actor_id = a.actor_id))
          GROUP BY fa_1.actor_id))) AS film_info
   FROM (((public.actor a
     LEFT JOIN public.movie_actor fa ON ((a.actor_id = fa.actor_id)))
     LEFT JOIN public.movie_category fc ON ((fa.movie_id = fc.movie_id)))
     LEFT JOIN public.category c ON ((fc.category_id = c.category_id)))
  GROUP BY a.actor_id, a.first_name, a.last_name;
    DROP VIEW public.actor_info;
       public          postgres    false    212    216    216    215    215    214    214    212    210    210    210    889            �            1259    17550    address_address_id_seq    SEQUENCE        CREATE SEQUENCE public.address_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.address_address_id_seq;
       public          postgres    false            �            1259    17551    city_city_id_seq    SEQUENCE     y   CREATE SEQUENCE public.city_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.city_city_id_seq;
       public          postgres    false            �            1259    17552    country_country_id_seq    SEQUENCE        CREATE SEQUENCE public.country_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.country_country_id_seq;
       public          postgres    false            �            1259    17553    customer_customer_id_seq    SEQUENCE     �   CREATE SEQUENCE public.customer_customer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.customer_customer_id_seq;
       public          postgres    false            �            1259    17554 	   film_list    VIEW       CREATE VIEW public.film_list AS
 SELECT movie.movie_id AS fid,
    movie.title,
    movie.description,
    category.name AS category,
    movie.rental_rate AS price,
    movie.duration AS length,
    movie.rating,
    public.group_concat((((actor.first_name)::text || ' '::text) || (actor.last_name)::text)) AS actors
   FROM ((((public.category
     LEFT JOIN public.movie_category ON ((category.category_id = movie_category.category_id)))
     LEFT JOIN public.movie ON ((movie_category.movie_id = movie.movie_id)))
     JOIN public.movie_actor ON ((movie.movie_id = movie_actor.movie_id)))
     JOIN public.actor ON ((movie_actor.actor_id = actor.actor_id)))
  GROUP BY movie.movie_id, movie.title, movie.description, category.name, movie.rental_rate, movie.duration, movie.rating;
    DROP VIEW public.film_list;
       public          postgres    false    210    889    210    210    216    216    215    215    214    214    214    214    214    214    212    212    851            �            1259    17559    inventory_inventory_id_seq    SEQUENCE     �   CREATE SEQUENCE public.inventory_inventory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 1   DROP SEQUENCE public.inventory_inventory_id_seq;
       public          postgres    false            �            1259    17560    language_language_id_seq    SEQUENCE     �   CREATE SEQUENCE public.language_language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 /   DROP SEQUENCE public.language_language_id_seq;
       public          postgres    false            �            1259    17561    language    TABLE     �   CREATE TABLE public.language (
    language_id integer DEFAULT nextval('public.language_language_id_seq'::regclass) NOT NULL,
    name character(20) NOT NULL
);
    DROP TABLE public.language;
       public         heap    postgres    false    224            �            1259    17565    movie_price    TABLE     `   CREATE TABLE public.movie_price (
    price_id smallint NOT NULL,
    price double precision
);
    DROP TABLE public.movie_price;
       public         heap    postgres    false            �            1259    17568    nicer_but_slower_film_list    VIEW     �  CREATE VIEW public.nicer_but_slower_film_list AS
 SELECT movie.movie_id AS fid,
    movie.title,
    movie.description,
    category.name AS category,
    movie.rental_rate AS price,
    movie.duration AS length,
    movie.rating,
    public.group_concat((((upper("substring"((actor.first_name)::text, 1, 1)) || lower("substring"((actor.first_name)::text, 2))) || upper("substring"((actor.last_name)::text, 1, 1))) || lower("substring"((actor.last_name)::text, 2)))) AS actors
   FROM ((((public.category
     LEFT JOIN public.movie_category ON ((category.category_id = movie_category.category_id)))
     LEFT JOIN public.movie ON ((movie_category.movie_id = movie.movie_id)))
     JOIN public.movie_actor ON ((movie.movie_id = movie_actor.movie_id)))
     JOIN public.actor ON ((movie_actor.actor_id = actor.actor_id)))
  GROUP BY movie.movie_id, movie.title, movie.description, category.name, movie.rental_rate, movie.duration, movie.rating;
 -   DROP VIEW public.nicer_but_slower_film_list;
       public          postgres    false    214    216    216    215    215    214    214    214    214    214    212    212    210    210    210    889    851            �            1259    17573    payment_payment_id_seq    SEQUENCE        CREATE SEQUENCE public.payment_payment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 -   DROP SEQUENCE public.payment_payment_id_seq;
       public          postgres    false            �            1259    17574    rental_rental_id_seq    SEQUENCE     }   CREATE SEQUENCE public.rental_rental_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.rental_rental_id_seq;
       public          postgres    false            �            1259    17575    staff_staff_id_seq    SEQUENCE     {   CREATE SEQUENCE public.staff_staff_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.staff_staff_id_seq;
       public          postgres    false            �            1259    17576    store_store_id_seq    SEQUENCE     {   CREATE SEQUENCE public.store_store_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.store_store_id_seq;
       public          postgres    false            I          0    17521    actor 
   TABLE DATA           @   COPY public.actor (actor_id, first_name, last_name) FROM stdin;
    public          postgres    false    210   �m       K          0    17526    category 
   TABLE DATA           5   COPY public.category (category_id, name) FROM stdin;
    public          postgres    false    212   �t       V          0    17561    language 
   TABLE DATA           5   COPY public.language (language_id, name) FROM stdin;
    public          postgres    false    225   eu       M          0    17531    movie 
   TABLE DATA           �   COPY public.movie (movie_id, title, description, release_year, language_id, rental_rate, duration, rating, price_id) FROM stdin;
    public          postgres    false    214   �u       N          0    17539    movie_actor 
   TABLE DATA           9   COPY public.movie_actor (actor_id, movie_id) FROM stdin;
    public          postgres    false    215   ��       O          0    17542    movie_category 
   TABLE DATA           ?   COPY public.movie_category (movie_id, category_id) FROM stdin;
    public          postgres    false    216   �       W          0    17565    movie_price 
   TABLE DATA           6   COPY public.movie_price (price_id, price) FROM stdin;
    public          postgres    false    226   +      b           0    0    actor_actor_id_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.actor_actor_id_seq', 200, true);
          public          postgres    false    209            c           0    0    address_address_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.address_address_id_seq', 605, true);
          public          postgres    false    218            d           0    0    category_category_id_seq    SEQUENCE SET     G   SELECT pg_catalog.setval('public.category_category_id_seq', 16, true);
          public          postgres    false    211            e           0    0    city_city_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.city_city_id_seq', 600, true);
          public          postgres    false    219            f           0    0    country_country_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.country_country_id_seq', 109, true);
          public          postgres    false    220            g           0    0    customer_customer_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.customer_customer_id_seq', 599, true);
          public          postgres    false    221            h           0    0    film_film_id_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.film_film_id_seq', 1000, true);
          public          postgres    false    213            i           0    0    inventory_inventory_id_seq    SEQUENCE SET     K   SELECT pg_catalog.setval('public.inventory_inventory_id_seq', 4581, true);
          public          postgres    false    223            j           0    0    language_language_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.language_language_id_seq', 6, true);
          public          postgres    false    224            k           0    0    payment_payment_id_seq    SEQUENCE SET     H   SELECT pg_catalog.setval('public.payment_payment_id_seq', 32098, true);
          public          postgres    false    228            l           0    0    rental_rental_id_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.rental_rental_id_seq', 16049, true);
          public          postgres    false    229            m           0    0    staff_staff_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.staff_staff_id_seq', 2, true);
          public          postgres    false    230            n           0    0    store_store_id_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.store_store_id_seq', 2, true);
          public          postgres    false    231            �           2606    17578    actor actor_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.actor
    ADD CONSTRAINT actor_pkey PRIMARY KEY (actor_id);
 :   ALTER TABLE ONLY public.actor DROP CONSTRAINT actor_pkey;
       public            postgres    false    210            �           2606    17580    category category_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.category
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);
 @   ALTER TABLE ONLY public.category DROP CONSTRAINT category_pkey;
       public            postgres    false    212            �           2606    17582    movie_actor film_actor_pkey 
   CONSTRAINT     i   ALTER TABLE ONLY public.movie_actor
    ADD CONSTRAINT film_actor_pkey PRIMARY KEY (actor_id, movie_id);
 E   ALTER TABLE ONLY public.movie_actor DROP CONSTRAINT film_actor_pkey;
       public            postgres    false    215    215            �           2606    17584 !   movie_category film_category_pkey 
   CONSTRAINT     r   ALTER TABLE ONLY public.movie_category
    ADD CONSTRAINT film_category_pkey PRIMARY KEY (movie_id, category_id);
 K   ALTER TABLE ONLY public.movie_category DROP CONSTRAINT film_category_pkey;
       public            postgres    false    216    216            �           2606    17586    movie film_pkey 
   CONSTRAINT     S   ALTER TABLE ONLY public.movie
    ADD CONSTRAINT film_pkey PRIMARY KEY (movie_id);
 9   ALTER TABLE ONLY public.movie DROP CONSTRAINT film_pkey;
       public            postgres    false    214            �           2606    17588    language language_pkey 
   CONSTRAINT     ]   ALTER TABLE ONLY public.language
    ADD CONSTRAINT language_pkey PRIMARY KEY (language_id);
 @   ALTER TABLE ONLY public.language DROP CONSTRAINT language_pkey;
       public            postgres    false    225            �           2606    17590    movie_price movie_price_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.movie_price
    ADD CONSTRAINT movie_price_pkey PRIMARY KEY (price_id);
 F   ALTER TABLE ONLY public.movie_price DROP CONSTRAINT movie_price_pkey;
       public            postgres    false    226            �           1259    17591    idx_actor_last_name    INDEX     J   CREATE INDEX idx_actor_last_name ON public.actor USING btree (last_name);
 '   DROP INDEX public.idx_actor_last_name;
       public            postgres    false    210            �           1259    17592    idx_fk_film_id    INDEX     J   CREATE INDEX idx_fk_film_id ON public.movie_actor USING btree (movie_id);
 "   DROP INDEX public.idx_fk_film_id;
       public            postgres    false    215            �           1259    17593    idx_fk_language_id    INDEX     K   CREATE INDEX idx_fk_language_id ON public.movie USING btree (language_id);
 &   DROP INDEX public.idx_fk_language_id;
       public            postgres    false    214            �           1259    17594 	   idx_title    INDEX     <   CREATE INDEX idx_title ON public.movie USING btree (title);
    DROP INDEX public.idx_title;
       public            postgres    false    214            �           2620    17595    movie film_fulltext_trigger    TRIGGER     �   CREATE TRIGGER film_fulltext_trigger BEFORE INSERT OR UPDATE ON public.movie FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('fulltext', 'pg_catalog.english', 'title', 'description');

ALTER TABLE public.movie DISABLE TRIGGER film_fulltext_trigger;
 4   DROP TRIGGER film_fulltext_trigger ON public.movie;
       public          postgres    false    214            �           2606    17596 $   movie_actor film_actor_actor_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie_actor
    ADD CONSTRAINT film_actor_actor_id_fkey FOREIGN KEY (actor_id) REFERENCES public.actor(actor_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 N   ALTER TABLE ONLY public.movie_actor DROP CONSTRAINT film_actor_actor_id_fkey;
       public          postgres    false    210    3234    215            �           2606    17601 #   movie_actor film_actor_film_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie_actor
    ADD CONSTRAINT film_actor_film_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(movie_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 M   ALTER TABLE ONLY public.movie_actor DROP CONSTRAINT film_actor_film_id_fkey;
       public          postgres    false    3239    215    214            �           2606    17606 -   movie_category film_category_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie_category
    ADD CONSTRAINT film_category_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.category(category_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 W   ALTER TABLE ONLY public.movie_category DROP CONSTRAINT film_category_category_id_fkey;
       public          postgres    false    3237    216    212            �           2606    17611 )   movie_category film_category_film_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie_category
    ADD CONSTRAINT film_category_film_id_fkey FOREIGN KEY (movie_id) REFERENCES public.movie(movie_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 S   ALTER TABLE ONLY public.movie_category DROP CONSTRAINT film_category_film_id_fkey;
       public          postgres    false    3239    216    214            �           2606    17616    movie movie_language_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie
    ADD CONSTRAINT movie_language_id_fkey FOREIGN KEY (language_id) REFERENCES public.language(language_id) ON UPDATE CASCADE ON DELETE RESTRICT;
 F   ALTER TABLE ONLY public.movie DROP CONSTRAINT movie_language_id_fkey;
       public          postgres    false    3248    214    225            �           2606    17621    movie movie_price_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.movie
    ADD CONSTRAINT movie_price_id_fkey FOREIGN KEY (price_id) REFERENCES public.movie_price(price_id) NOT VALID;
 C   ALTER TABLE ONLY public.movie DROP CONSTRAINT movie_price_id_fkey;
       public          postgres    false    3250    226    214            I     x�U�[s�����rNY���c.=�Н�L�jj^�B��6����ھA�����}Y{}B�wrd���KcU���w�=�O}�_�r&����+��X�sfGA<닩d*���\+޼��+��)���G�k�������x	zKb嫚���J������vo)�?��U��T���v�EY�J��(x����W,�	��j&�<i��})U"~��!����I����K����Ts�G $�H�Ă,���f��ʑ�>��B<�/�n���#��l��$>�M+c%^M@FN�k[�q,�YT	�d<�ʠ�ϞpZ� ���ԁ�,�T��� ^��I�s�6g��u�C)�L,k�Xm����.�V,�nw�X(ă�-��:��h<�G9Sbc���e�:9�Ň9������L��Ѹ=M���5C���L��mB-���>���L��肷{ޚ�j'z$����miH<,�hK��D�#�L��d�o0)h�̸�Gl���$�����P�MR�&�h,o2G#���;�&c5�r�O吀v[����?otE.	����޵N����q�[���8h]A���O��#�����h\-ST��t:C�ir��w�,�4���1�t�)m��x�8Β�o&-��&��|[ʴ@�u����GЮCH����3�QL�<K��y6	�3h<��5B���<E�E,��[���[����9I�-�X�J�)�%�T�y=���a��,BK�VԱ�N7��̔x(�����b����"�v�*�͆z�u2K���a��^���7�����P�ڠ�Y��i?1�a��+a,����Y��h��<B=���}�%s��F��W'T#���[zhC�3�~���9�ŭ�pt;O2ܒ`\�^�gDA�ksa���爇��g/�Ll�e�~��VL��F�����q��"��6�w1���xM��"��j�RW�)�<nc�LGu�W��8��Ɓ�B�c�E��!��d1��n�=F����f�WQ4%�L�3P٦B�=GT��B.��w�h6!�`�X��aHU�����_a�
.D��ύ�`��ò����`�:$���H,b��Uu���3��]7��uSUX�4laJXB�>�y��P`Ұ�ږ>@f���O>���;��~0pALkD<�FL�:sU`Ӑ�r�r>MZy<�R�7�Kw4�7a̴.�܁����zE)@jR=�m�k��A==7�L�M+�@2L��r��tM�XՋj��0�4�
�Zj3�bu6�z���3�-���A�Z�0��Zk�W��u� �������Y>6{2���F�?R��]y�0�]@�σ�go�V���W	�m�s۲��d��O%���� 
�z�h}����<XZ��S���dl��T��`�������0���(_@��R���j�y����#d����b��0����]�s~^uAu׬4ڶҶ�Y�t���ս�o��]�� ��p�< �B0���X�8}�bX�y�'�@�X��t>pj�)�������	w3nq(lA npWt��O���F(�c}T��ö�3n�;2�]�O�s���`�A���JҁP���
���d
4[��+��:uO�*���JO3�A�# ����K�{��F?}b�@7��g�µpd��Fa=Yχ�wŞ�ہmH���)���eݙc>�cg�`��sS�ˣb���=����w��b��2��ħ��	s�� �Ǻ{�8Ũ�a���~0~�F��Px.�=v����K���+�hI�.��/�H||�n{�WJ�/|��      K   �   x�̻
�@F�z�wQ���R��6��6�.�Ef%oo�;��a:�ɥ��N��wI���QmDE����ɨ�M��꒙����=u*Ap�^����'���;:K��tI�I�]�u.�f����6��4��N�n���-��5/S      V   R   x�3�t�K��,�P@\F��%�9��y��Ɯ^��y�ũ(�&���y)�E�(ʹL9݊R�Q�V�2�tO-�E3Z�+F��� ���      M      x�����F�-���)��	 �Swٖl���b�8�$��$��j�O2�U�U@�D|1���%��r�j�^�ylwݘ�ri�}{\��޷����Ͼv��n{�c6�gm�y�]�긃�x=ߵ�OϏCv��/�?�q;:����[�����n��E�\V�բ�?M�X�6����7����u��0g�k�]7�ga�N�6{;��V~�M{Q�}��i?��Z�ݯݮ�fu��W�G�-�g�f��X/^��i/ٗa��O�s��}������z3���xq~������r�y�,�ɦ^����K����K7��.�O;���tŃ�W�}R_��c�+�W��m��r��gqٯ�%{=�����ˇ�^�a	����}ۏٗ���u�o;� X9�������jǛ\���?�uzȲ�:۳{ԯ�o����x|����y�5T�W����� ��/��؝�]��=���w�>����~��y۞�߮�!�1v��������غ����
>���R���W��bΗ���n��mto��	n�o��|�O�����*����9�c�w���~�^��^.^����8���?+�G��FX�+��pAO�"��}����cw]����~����e�Ķ��%~���������v�_���ᬺؘ�����=g߇gܷw��L�ǧ��������җ�m�8���:ɫ8,z���p'�=܄�Ye�
�e�~�^�{s��by9Y�������9>�����.޽r7D�
�ݛ��.�s������Sw�8���G�Jެ5@
�����; 8�:ح�}���T���|��u<_;
p�ľ����m���BUۛ���C��}�>�{�-�!H�%|��.�#�v��ы5�@��Ý(���[�~�/��	Ĺ�����<��x�^�;��W;	oc{��� ���G�gY�(j��
�q�p��S�s��<}��xߋ��[��^w#�Pw덼EK��a���î�� ��G��uSБ�*�0��0p��x�=��X�ɫr�����>	�1��^�N��H_��Қ�5��x�xuٷ�;��^ϸ���[��w`l��#��mFC���������~�1�Z�����y�>�uu����o����f���B�:���6�q�`/.���`�{�.мA�
(�L�x��#f�������d����� ':�X�[�6���E�+
Ur��<���u{w����-2��?��3@�F�G}֜�����w�\[������a��ڛsc��vx��d��&����B� R>p�z���c�O@������f�2]��̖����
e�\|n�3����ԁ8��������?��������������o�q{=g�3\/�bχ+<z��ˡ�����h��!~����uf����l�X���sd������2�h�e����Csa��%� ��7�n8�p��ᓟ��R���K�\�:�q�W�7����/}w��?�L�{u ��IOǢ�|�货n�Fz �\�Ҟ�9x@.�7�n�YH��D�Z��_������?t���s�{R��"��Є���ޔ�y�����}��C�/��%�������$���Q�Nk���]�� �}��y׋���8P���	Ƃ���� n��P�}��s�39<�Ƿ���_集W�u�t8���#j�������<����Ǘ���o�-�>������=���b�	q2%�j�k�n����ʶ���k��[�N�l�{1��GR���ak�>^���ɇm�F�*�w�l����B��#Z�=Jt%�i�k�7�����lnH��9f"81#%Xq�?v�x�;t�iJ��Ӿ����I�����[ޤ�}�^6��1��/���S��˸0NREy:|a� q-��Gp��ٻ�/����K�:��j���{�+?w���]�Z���]����(����
������
�RQ��x����#��!�=����{�͵2�xx��v@V�Y�j����$Ct܆�'�5o�K�g�z�L:Nn�u�W+\�a���w�pw�:��V����镒 v���O�n?q_|,�Gz?�����G[��D.�ʹ��;!*9P�( �S�C�Ky�������:)r)�ңO��4���W�^<��LޑX57d<������=�;�Z��Н�(l�������h�:.9Y��|Fw $���O���'��^Fw�YY�Od+���L������,c�j�����8���ȸ@�i�Z���#��������a����r��#�`,��(�P��Q�(d� ��=I��p��R�|ZPK����?>1n��сD7�9�����^��Ze����Z;6z���Hy8�z�ߊ�4�ld,���=~��^.7I��� ����ߺ�� �4s.Ii��+�w�������wL�!7��pL�If��޸��E;t�n�%����.H�,�h� R9� #�ғ�5�۲�&��
�,���pJ�e����ڑ�D^Q$j+�K,��� �����|=�{����I�׷�/�E2еrx��v;�s!ʦ��"ps>a���عW�]I�jko"��6�q�~~�n��^��>�:%�<ɱ�ƎM|�L�J.�
����}���J��d.�y�\$e��'P�7��$~�{�_�Q��;L5�.�@�0�e�3�5mF�R 1���vT�W��G�a��f9^�v�:e�% ���cw ���Q���./��e��rTL=�W2G�2h
�و�w��/C�S��2w��MlGa�uy�$�d���rTBp�>j�������N�D����ˉ�[��Б���?vA�c�nT>����?�;���^�0a������"�;!�c������>4���6`��������8�)�p?�1��d�%��S�/����؀��{��r�f��u�*���P-1A���]+?�q����3ұ^�s��T��(�ݲ#,īJ:����j�V�k#�1l�k��>���ŷh�1���Э�+�?���F6�W����Wݎc�y9�X	������B�}�r �V�]!�>�+�m/H2�;�Aj��m�(���V���_�����g���zl�E]��;tov�\T�T��5�k�`�L�Z����`G�珰��c������w�H�f�I����b 29��ĔBl��C1'�I���D�c�T�����	mgxՄV�/������	�a�~���Ǻo����3p]:�b�~���/��_Eo��a�8<K'����1���#7��ʼ��M*�&m m��Ӑ��9,� jW@ۛc�*����,m�`��r���W��1u
{}��>��fQƘ��S��P�5z)"�{��9H��%+�C��r��S;Hq�cf<\z�]l�pyH&yb�WL��Iy�p�����TI��¼��*9<+�Yɲ��ض��'�������E>|H�z�*lQ��qξt�W�X��#UfFB4s��K| ��G��X�+���O��2�CB�|�Hr�y^���Ci��W����:��g����{&<B�)Hb�E�^[����<0��K�w�j�}u}�3��	:��>S�k�C�E���?\�"<� [���>�H����� �Ȕ����y��U9�O����^.�_~��>�n���5���ڝ1�w�ۋ���7�X��#�v ZÜ�7���Yd=��o�Q&�c�~/7�Q�4�Z*���z�����m{��Ŵ���b���|K�ιT�B�m����>�����#u͆��2y�-�;�&�n���.��̐<���L���!3A���T5�*�.�
8��hl�W+��{<�6.y/��q�2�9%3����9��/�Ui .���ق��<ܑ�pS��ǏYH���!\���.�|V��#ր�VZu�Z�����yj�����W���tx�u���g�ْ4��%�̺Z9"�~c�q�7_�`��8�o�#ܿ�d~����)O�_uKFS�wv���1	g��l>���&��    L�}��,��	A��rrꦖg�!^���5�Ca@����T���pt���1o���{�?�z�ve�-p�h���?\����m�pB
�
�~+�6����h�6ܐφ�N �z�.� ^�T�˦�"<M��(�5؃����KC�aDi��^�V�d��+\ƣ��k)���Р,��.���鍋���Z-	��z��-�x8iC���X��eP�T_��n��m�����lHL�4	Y�b�@��z������|˾�����\�g�fzt�d	^��[I��j	�v�����T4�Dҁ�S�uB̙��rK��T2,�y/��T�v蓟c�6v��g�o���8\ؕ��4,) ���,S�~��Lqu6�-'>v��ӄU������Ѿ�)�
�m�C܊�@�.�����}K����-�g�	�n����]-o�;�/�cM�L;޼���(w<�t�,�j����v7x���v}��DK�*�|S�I��J�\���щ�� ¸9.��l�V`�M.
�w����H.Ez ��1����u��S`b�M1��ĶU/)��J������^F@ ��*qQ������D3�Ջ5��a�i#�
��;;�:i@>~�l�i��QO�2Ӱa�Z�b��~R���@|�P���Ҷ�/�YI���^�[U�n� n��LR����Y	c�%�'�W����ƞ��/�m:�N�EI�&�'>n�P��LjDޱ���}����9��ϥ��x��ď�C@X� ���j�r�vf}�$���+U���7���	7!���������YN�H$�� .�!���@?G&'x*�2u(�2b��3E\��XA�{ ^��Mq �|��dd�p�C��iht7a%��ȏۀ|g!1귲�\��51�jr�:�ac��m�#��R�B�Pȣ����yi�R*6�M�O��CD�J��vC��1 �K�k�@�P5��h�Iwz���9���ww�G7���2ÂK|1��A��#qek��5���C�m 6��G�N %Ӛ�@BۡT��:G���xn���.R��2·y�9r�7�[B��7�����l���Dn��T@ԋt�
�I٠8�z����kw��z��G��}���	,u����NQ^Q	;#�ޏdK��훸 ,7n��
��"k�*�]W�1'8	��[�a��涬r���7	^�g��n��f!��`�z��î&7'�p�Wh;b�a����k��~���ň�݆�-��ӔgP�a�\�Y���.�G�^��lohD�o�4�m�����- QeI${����i��$�ulZ����Xz���c�P�~�Ð��y#�I�	 Ń=R���(/r��������n����}",����\cx�R���"N�i�X�$��
�)�vI��s�4�$ه=��P'�%��e-��[uz*���|�2;4����3�*�K���uGN�8�dɶ�ړ�
�����UkW�DW���>BHs��mtuj��<���kK�_,U�/j�y�G.�z>�O���e�)��YTUp�Z�
X.�����x~T-	����\�����+p2�����o�z�ݹ;�
��%��&ґ�>4����zӣ����~����ZR��x�3�is�ЂdeK@�������q윲��a�#T��1�^�@�R�X��1Z�����~,�"0��%	sUV���	�Qؚ�扝R1xqaT�_SE�
�J@_}`�_�q�̀�*r0�F*I�i�Υ�'v7j\ѱ;�z/:��^����BE"*��V������S�.�yrD�tM����Z�(��f�Ü��=���2�c�g����V�aJ漉G6����V
c��Si���+'��Ӊw�QD������ɲo�����I�p������ ��F̐�ۜd�ϙ4 I��v�y�?ѐC �g����	!@ZvH�c���z�뗖����q)��~����p�z�N�k���U��n@��D��O��&�]s����P�W� ��e��<u�f��G!�Վ����@u��a&��UH� ����N$���W6���XU;1-�Bk��#r���7�M7C�}�h��fT�X��`�˫��,���9
��;͞"�NT7ULr1�S��$��
qͫ���2᜸�Ղ�1�b M={tn�cJ��dMg�<�*��������a��7Z�M49��c�I��'���zA��g>\�7�3�[v��D�����M��n
��^h �����gm�m�ƨ5M�Ry*�R�� �2UǍR4�����,�;�BFT&B�� ����c���Np�m�C�d����?�:k� �B[�E0�j��� h5.G*��ۨ vS�U���o�+���(�M'��y//�Q!��Xx\p��ˎᬹJ��:�3F��j�V5�X�t�e?
O%څ��[`����3H�5�q�r�L��%��H�(ƹL��XNjh$D"*�(�,�K5��-���n��qAY]A�ނO|�2Qo��#f<����,�}�5�����u��0+�Bxb�u��t���iΝ��BW"j�6��D�����;/כR��Y�!)�\E�� �`abE���Џ����.��fŻ��b^��W��M��#����<�H���Ÿ��-^Ѝ]�'t�w�ԝO];��_Ɗ�,aQ�,�����5�%.�;ao�o�����lKF��o$�#���N���A�D��#�8���E�����9�0���e���0n���^���Ar�5����R����8��k����.�����)��=.��l
\ѳ�:�GV� �B(�M?���R�#�R,6�{��x���
�0i�T�\[��F��b��ۃK���=&�v.!�ˇx�˘%�HN$G�������s!8�g�Y�h��
K̖v6���|;_ �t3��&�5ۭ�0RF�|�n�K}-�E����݀��p/�~	��&7W낡�҃��ۧ���rK@��xi�2�����{���M�Q���b`���m�(������s�k|/T=y '�[Z�t�/�"����|w8}2�|lH��bJ5���|�Ҿ���ѱ�7��=�
^���j�a>�V��so��A  x�`S#�ܑ~��G�˄R>Y�\��(a%�-�3�G/���NO��!m�j�<+]Z��-�E0a��Ub�w��)�W��BD�K�h�K���b��L��R�/9hj�Чd�e�Zٗ��2�-:I}Ӧ��b���!X�য়�����Ϻ��Y�������vC�WK���8��!��h�7>��yfT� ̵Z-T"�8"4=億޾���WV$Q��<�#�y��,Mp)܇ٴ�B��ע�+��`H��ǾqǗ�ޏ����a,����Q��!�=�ǝ[�	=��h9Y�G���9���X&D��rb�!45�%9��?3F ���b��FR�U�ė��Yd�y�))U�|�V	p�m��^�䦳Bk�ͫ���L\cbi"ܖ� � �Δ�M�ĝ����d�����,�Y�\؅����P��~���DJR�{��� [����[��U���lS�K�>���[s���T�,�R6�����]���B>;�$�\��,f�B-a���L�p�D2�o.Z��5��2L�����|.(r����p�H+%�i�V�(7:��iT_E�����\�E�6��N��]��:��/Ҳ���t싩�Gop!�Q�,��r�H�Ҁ�-��s���=�i����j�Ƥp��ɦs��׵����t~~v g=$9����̦#Z��2=IB-�-�{�^�K�8�v�̭i03% ��m���@���
qA�M�'�*�~��/U��
�[����R�t���-�h�Zj@n�f?^`��!ŕߋ8��t�h�k,l�>_��Y�O��>J ����0����!o�m���s:�Z� �;a���x�n}�2W���rhN'����\�(c�������ۙlDi�8Ϙ�K�U���pv�h��R���J�z%�8)E2�fvFQ���f�R�p���g��q9    � ED���~Ņ~Ā�V����u������=�R/�5�m��z>����2?iel�;���� ��@���.k\~;�;��@B�K9<�R���~/r�1�U�$U7��F-Ѷ�@X��RU�?#�M��-̤6�r��JFp<��	�PX�q(�n�/��"��Df� ���Udi�ߍ�U�ֶ��h-�iK4�tٚ. v�"R����i��r8�LJ�s��S����X����O���A,� �W�v���I	/q�E�T� M3+�wG�'�L��A�{�쐱�Ӝ�%����<>)Y�#d�[^;�N�̔V(��{h
�yݣ�E+��tbb�Kk��G^.R8ck���!0-�9e�+�\Z}^�F�l�(2�T�7<|�P*R�C�5�< �ص�k�O�ӂ��@�ҡ�%������*B{^x��=ZQO�L,*P���r���]燐��<YX�O�W��z�69��y��1�dP�R�F3-��"yT�lRq�]Sb(��9���p�׀�e�.NƼnE"����7��R�y)������d���H�%w�ވ��%ܰ�K�1*mZ�b]��������լ���ϟ�%�lu5.v}�{�M��y��K
Ke\���$%V�B�]�T�Ƚ#,�O�Y"k�*��*��<�����a�q��H&u�Tn�ԅ_7�o���t�� S�	�����q�*��������4Q��c�>�Tf����* �g��ϙ��霈��d	Qߐ��3���>�0�@���#�Keeb�!F��ˡʬ���j�x�>�^�>���{н��@�?-�;q̻'�(V'�v��b�;�`/�,R��7�y���Q�&�	����ό�t5ʢ�k�<�4��F"_��Z��-y�ĪB�k�7Gہ�&;����	RG[���`�o�Ż<��z�ˌ��ލ�3c�z�i�v֋w �ۋ+p��q��?�t�y���ɛb��n�Ýہ��Z����5sՉ��X�o���cw�k�qR�N���,6�F�%S�L�׻�����R��iB�D��h�`䊭�+��BN��:���s���QQ?����I���w`�?_�3]�je9���|$�h�U>�ӽ���w� ���dJ>��y����|#��yX|8a��s�~��d\+�S�0�23�*5Rc:q��X�M(A��n�]���<���9S\U7�qȈ�ɱnA dѥn�	 +	P����s�}�H��:�v{X�bs��n���N;$��0��l&#�LrU��w���3��N�t�0X�d�3-Ű�y)5��b�?�wO�U�1^�|��j�a�ր���I`�7�K��V���=�-x8$!`��s�7��]~�*��N����̋kC̐�M�G:�:�����K�j�j����4���*��,qM�)梽��:H�M��C}�.�ʑVj&C� |��Wa�u`���4ww��:�ᶓ�S���	�+
[�&.9��͋5��
ޥ
6�R5~�|�1�̹�]F�����f�Tʜ5�����"�����sg�z�����ʛ�&q\�5�p7���q�x�p���P��M/&����1B��fM{�n*���<�=��H�]e��2X�)������<� �x�Lkv�NO�k�J�N����Z1D��n�9S�d���$�J�����`ś�\�f��ҩ]\��I���b�[�MW����U_.a1�- ǟ Q��|犢>�ބ��1DK�˜�`��4l5����t3���1�`R,�3���p���羕!Z���yTAE���U�X��<�˵Z�c��$�]V^$r|�	��ޫd���1���a�> �=��dh�����9<��R�H	������UMf�]y��X?�Vh>6�mk��=.ǐ(U�e*��i���@vD[uI����������r=��3ݒ�?I�w�r���^ְ�`��¹)y'��Ie#t�=U�Բ��%`cw����5	~|�TkOt���"�ʄ�W ����<UW��"2,]ʩ��R�����ȄF�]���c;��	Ii����w;��O�(�(W�Pg\��[ѳw�&��۝��Ѣ�QI���cX������*2-�^J
��k�|��W.Qҽ~J�MO3��S��f�6`��1�c�{��M�����g�85II�2#+�@�^TbZ�ǰ�9!����1r�~~t�Z}z#>}��׺��ߦ��;g�k:�<,��Q��3���˱=�t*!�85
B��9��-������t=�1<��&�s��?�ű� ��'�B�^KS�%�:J�j�Ƣg��W[R�:_-�,7��f����q ��}~cdn�8k:��	q�Ұ
���Dը��\74fq/`Y���>��|/��3�N���UŘׯ&���q��Y�����t�Z�/��\�y��\��11���e}��gwgw���	�m���&@Ե�̡h��(��4�79_wx��cH�9%�0s��a/"`�0�a��1|׏��S��0|�dζ�}pƳ� �HB����d�g��f�N��iv���nF�P��8,��~	��o�0��Vԥ�1k�L�tF�KY��9Z���gB��5l��ϨS�;���W�qL�˙ ��j�'�Pn�dY��#N��lSQ���N���glټnI����[�n�7d+$��	������S�S�ܱu���d�����W挚r�Tc�*�^���n72�Q�H	�L�UT��i ⊅DFf��W�o��t�I�l։(�,F��~�������AH�"�zU�Z2쑈$��:�^���
D�H뎮�s\N�X�J��Oj�T�R,q�w
���]��"18'��a;��b+\�eZ�Z���m�Ѩ�Y�Z�� ���ͱV�W������GD��?���Y ^�ngZ�z������4FȰM�w@�
0�T��G��i2O50��å�G؛Q.>�s8��R�4H4|S�AJ!U����Eٷ�D�c׎��D��`�`(7�$W�&�i�����^ה��SKs���BD�uՐS�2�����^����}�$�=w�#\Td�����y��C�S4����Яu	��M�_�J����Bȅ�ǖJ�$��*ZĊm{��b�<��҉pF	�wA��������yh����ԭ���j|8!��lb{���ogk��j�n�Eb(�ױ>w�i�\����#Z�#���!5x±�aXGG5M)ƕꞔ��w׳ jI�y��t�DMW�Q�_�jyK�b��E�ȋ���"�Ϩ�jh��I]�c�e p��;!ot����tχ�<Ʀ�d�
u
5. P^��C�H�rC�TN�'�(B#�T�~�ÂA�kB&4c�`��:Q�3b���s�检�����v-&�E��+j9B4�iP�R`(&�W�f?�Ծ�v�8��$d� R��yW�E��J�s��'C��֊9�7�"e����|��lQf2��	U�����{aa2!���P�sbB���6Y�ސ�0u���k���%�T'�������t ��,k���Qp�z,�E�&��m2b~~%Ƽ��h#Vs����m;x"[����G&��K݆!�0	�`^�sF����NOQ�r(dSs�j}Z��\�n0�ue����&=Q�i��CùS��С�k�����A�N��En$��_-U��]���~1��ڕ�h�#�;�e�)5l�$u���V�d��N;^�JOLM����6�h��X�}X�:vWT_�4I~�ݐn����k���֛b���~���Y���Q`�pW}5˅P��h�8X�\��vf����"c{����?��ԑ����+�g�-BH?���zqe6�G1��hR��x��V4���:.Xm�����̊�qF6т'W7��n\G��:"�K�t�ƣͽ��N��W*K��5��)�tt���i���TC���:�Ӻ�k�J����g�etk�^�合bl%�Jz�Z�JͥX׈�=�F=�5�r��kf��W2�*�+)��i����G����S�%���sUc�5�� h�)�W�Va��R�6n    ����[V�R�a��+�z$�#�]��VB�'9w~���� j@����ҹ�U=A� �h6�$��Sj��+ ��84�~��	"ng��R1�Ď��E�#�Y:ʬTLX��+�x��8����!�������| �{��L��ɓ�d����n`/�70���nO�E/��9EGN�Ty��j��!��Ķ�	�Tǔ����	bY�إ|�+���s�s۱�i�������Sr�,���:��;�y{�vBZ�wjR�3���z�b���V��?�� ��§���g]ŵE��/ �#3/7� �evJ?� �DZ�)�4%�Z��U�/ d[W�8!���/�<?�5��A bם���"5IF2�B��M�2�X%�{��?�t���h������"�ǫ��T,'����	k'k|��� 	��J�M�j�"=O��+i�pƼ�]��ݩ����VC�k���g��*����w{t�����H����g�I!(����]<�%���I���x�UϤ�8�t�\������V�o�X"z�'LC�\uZ��1��A���ib�z���{��ˮ}�/�v3挓��U,�/]����sst���7I��q��o:X"���$�@�xĞ0un�G�m���o���%��*�)׻?{�j�8��9�\N��)k�cd�sB�}�hI�L�ꋳ|�PRQ���B$<m������@�e���9js|�Q;��Ƌ���1L���+��_�_���~���h)c�b�ĕ�u�Ko�����Q�mSwEEʏ�CT�x!�&@��2�x@������b��uܞ;<�3�B����,�1s�UH��յ�9Sf�����n��?U��k��:8�!�"3��UEw����U�v��������4�&�&mJ}W c�뙔�a��=e�`ܜy$��]+*�+V����%.�YP����IKX%|��R���G-�������~u�w�B3���%f��R[��׫��a2��`��{��޼׹�$H�G�Tg����������9��Xg!���S~H|6��%z�"NQ� �1��$�İ��� '	V�  ���Er��H�M1A��D
B�,�� Q=`�pW�M0�:M�0�
G�}b>��xA�Z,��<x��zrFjZҙ���re�H��(��ö�?�#��	y�P��$R�t����������N�>��b<����'X�j�O�R�}�� �E��i��|O2�E~�\�F,Bt���w�<��ɡ��QzcJ&�j%���~�sS�����:x�$<��9��2ϳ\.~�`.��n��o��̨'�:�q�T�b��4�{����n����~!���%O�ͷ/���%K6U�c�����p��+#���VġhĬ�P�� ~����|\4��+gF�Y�ڻZ#t�#8!_��8:=��Xĉ�	�l��Z!����&O�g�� �Ԯ�@(I�Q�165�d����'�0�A���X����SN�9k�/��)"�a��(Iӯo}�d2R ���p���`���
=�no��MSapu &��x��/Q�^R�̍%���*�N+@���V�grW�%.Yp_��>�;��CѠ����29�IQ �k+h�{K&��G�MqX�K�3�X������tJ�(��\�Dr#OG6��( n���k���������'�=�L��� ���m, {���|iG�8�{z�d��E��A���DX�mH��\�j�FU�I/�ь�Eʔ:�_ ��Н����qIT�1	��$�I�@���Y��E��A�z�S]Qs��������4e[�e]�^��f�Q�sL���P��F�))� ��a�d6h�k��[$�M�jX��	e��e�RhbX�W�p�0�)��"u#���P������u�J/��$U�9!Boq��-%4�.Xx���iw�ް:����������JQ�k�q�ۿ��~6BE��l�v�&E:�w�Z��\�_;����/P�%�h並���0��qסxg����k�X>"��74��c��˨�Pt�B)iEC�3�|T�4�i_�[6���a<`S���	Z�djeʾ$Gi%�g���r<[��<_���+�:*�:��A<5 6�����=��֟��?���`-��_�!FĈ�*�U`�${5��y��z����$�,���W녞l�����0^�Q���2��$�2�Nh�4I���_w���F���pb�*-�ґ��6{9J��"���S��g�I㾠�Yt܄@��Z�� �I��T�c��{�"�{X��|V\��3<g2���d��/c�pE%����_cM��G`1"����
.����V�6v��ؼ�r��}g]W^�O�i��x�ס��)�?t�1��a�1���~T���#���E�����q�ի⦿��Jn�� ��Lˎ��1Kn�+�4�N�1�9S���`1��������!��s��0iV�k#����z�+��%�J5�$ϙ
X��h"���ɱ��~mq&�Ur����^�p(�j�߳ʳ���|ʅHA�}���Rb-nIT`�.�n��d�M_���ܓK^���ڄ�Pb��5��6��mS�^���93��,���y�\�J'���Ǜ�X�/'�l�~�(�&W�,~�v=��Ǯ�ۖ�M��J���$��M���/�_�v
d?:� �6�D��=�j�����F�{��{��h��d6��6�9�S���L��3�q,��]r��E�UcZb�ŌN�ӪE@��*�[>_�-��`c\���45=>C���6��?"�NP��S�Z���O��V�I�R��K\��׷�|�y~�J�һ5�dr��I�06�cXU��i?h����Q˩�P>#�F���*�'2�������BF&�Y���|��J�P>Ku9���\��G"��<�XrhI��p�����_2��θ2oıd `*ӻ!qX+8�Mi #���/@齔(b��\��X�����r��7+\�	���(��y�D:N\X[�qq�*�4��Wq%���-6F��#	}SNLk=+o�.`���-ĵ�Ȟq�:y��V���F�rS�7G���h��8g�c�I���zP9Ʌ6��7�o��'�����Uĸ�vn��.W`8HM���L�����u[�i�^5o��r�aD��7�՛���� �d��0윔M���ӀL�o�"G����^H�Lg�&�}�/a�/���S&�!�]����o��9_A�T��L�xi�gH<Y.�S�	]�EZP��%�HΧ�MSI�\�jX.<��~���fZ�̉=�����S�+�\�'���>�(��0i�!�s&�ݬȎ 6�������G9t!)Q���c��U>����m�i���8RX�z���)��G-�9�����]�O]�p+E6�3��cߨ',��H�A9��2���¦�Ɗ�%��?��)*�)�_}j�(��M�f���u�SSԥ��џވO�]�٫K���@��Qf���$Ec�0Q�Z��a9��s���P��>����cy=�!($(ȝl��Ǉ+Vz����J8�������%��H�\-a�{4�f�:��k$'ȉ�aC�b��O��|i�z�y)/�d��y6%ل|!a!��'��-���x8������\	��IN�:B�}��Jޟg�g#l@S��9%1��Vt7<��z ����e�ݬKHFഉ�с���SՐ� �w {7�%)�G<n���g��i���H����!QlU�":�k1���z�I�MW=ZC�z��^�(<W����:�v��&yOo	�\~�ڠ��Ȍ�t΁����-Oh$��K� �=��"q���������ڰ9��p�����UB�	���G�=uByʆ�.�8��)���\	A?��ɾ���A ��ƚtoԁ�2��ÿ�������+Jo|�>y�k�/$
p�h��&�8���9�y�eߟ�w
I�8�u��6������&o%`�ݞoe�1�?g1�ˋp~��$�Ff��p�VL���� -C�	3��dt�@s mp	EP��;���f�.�IS��MPR�eЍ��׮����X�-�%g��^�    ��s:Az= ��I{3d<�%�<���fץ>���_��{��%���`>�� �X�.f@g����Q����p��JE#�D�I��.� ��II��6����6fu�R~�%i�k@w|�xj i�M���Vh�IzIK, ����\,k����%�ׄfXU��D'���y�k��E�u-&Y�vϨo�HZ=!���0�SZS(v�P쳉�ͮ$���ҙ]��O8��h >zD�I�&��fsJݍr]�����)>��'��@g|�W֭��l�jF�,��>��� Le&9�)����w5�m�pΚ=g�{�^��sM�HutU9�
 �W�rj�&� H��$9F�qJ[�-���o�*8�j�jL[r��@c��e 
�g��z8�tc�D1*fҢ��N�>��be�Z|n�O�#7Usq�[�_����ϯ-@j���d�9�3s[*"96�=+��T"Ne��_�C�0�c�f�����|((4�V SQ��F�f��}b���^V(�Y��!vf!�Jt�bd|w��q 1ZE�ˀ�(GM-�3�����@��(3�&j[a� ��/}W�Xwv��<C�3�}�k�����wY��`����O"��o|���Ԥ��kV��eш��s�ff6��L�Y�����H��bwjf\��?�M;L��D'2$���n�-e{�P��%���Õ�2��n�H+B�u���s�/8"�K�h_'��0j�E��v��k�D4FR�y� ��)���nh�#­\��\�p��f��щ�&.P`���cJ�b�� +Kc	,Vz�S�>��u�[��Z�U��� ��!&8�k|7ϙ�Q�C�&���c^G̷�����w�n6"��'B[�$��k4-M��M�D���~���$̸F��u{��5ǾPs����<�w�����ʅ��x}��sæ��9�2�?�T�g�����B�8�[��L�Z�彏�F��>�.j%�vʪX�y �h�%+���b�B�VMqnNW��,+D�����};�2�������K�O��#�Q�E� ���&L�1(2.-�q�p%Z[V  PR��8��QN3�bA��6���R�!�
�D������k�w��=�:Q�b�-�M�W𿿷�{���*��Q9����U���X%�U lݱţ�Α�#�*��﹌�����T�����n<�����x-p&☤cK��%� �&|�.p`3%��f��"л�U��e��⡸�]ҥ��F����2'��XZEH+����0��X����I��Q湪����8�&x�e�-�wGq�d�#���r��1��cN\]�+[���R��Sm��~�R{��sX��j
Uw� ��Ͽe�oKt���ʃ��ܤ\�������g�.���%7qm|��掊�����P�r6�ϻ���"�����$!�$���lsО�9�@"�8I��QXM�~�/푶��	���ͨ?�ͦ���R�p�*�F���JI�mzY|���ш�R�� U����E:����!p��,6���|}��z��ya����1�.8U����E���/�ʞ&93����,K6�Qu��p��{�i219�u��pH���[Gڬ�������]?�2���&�bMNc�V>N�
�=ee :��[̣vccǓ׉Nw�V�;C�ײ��� ��{�Sݓ�L]�Pb)�nėGZ,�i98O2����Xns��G�w���Al
$)j���P�\wY�o��g��޴׳Ǔ"�y�,�;��2P��E�jm��\|Y�j�v��[_���@�(�e�f%�����Y�Ựӆ�v�(�hYN��d����j
����"��x��y�?(ֆԊX4���e�@�Т��&�'
8��I����4dS����x���G��@���fj�re	3+2�)&4���v����`M���LH3�	�*�� Н�\?�Kü��_FN,�^� �A�ӿ��E��)]n8��"�~t���u��%���z�߇:q�yl���V� �TJ��Z"^��n|���,�&��9��r�D���"nf�;�	GG̽��:�EKn��̟�X�Sw>u��%��dZ 81+����^��R 81�3�������!%�{���9�
3�0��P��CS<��6}җ�R-���ܼr�7�)%`�;��u�G���z�M#ZB����Eu++0�����I�������n���u�9|ڂR{�% �u�md���i#���L�m�s��E����93��ԯ�iqF-!�'�5T�%.���:��0w���^R�ͥLD�Z႔.��'��Ƅ��� +�oE�Xo~�Qb��g�UX� �ӓev���*�08�lf�*T ޟo� oynk]��aR-��a�`�������)�̟Nv4=��[���,e�T+����蟟�8~�$!b����ժ²���.R�K�&b0�&�#��\����#����T"q:�v�4'���$�h��w�,�v�4;����oF谡��e3s|�R�r�3��7�A�HS���=JJ}U�B���r����בLv��`nҮ���3h`v0���8=�{>cە��n��2.3�Fv�}*�Y!߳{�������N������4�6�P�JOL�r@=4�V}��E�|�p�Э�@Zۚt���X	�߀�ͩW�NT�M�ݪ�{R���4�(I4�+��1�Ҟ����V��V�;������*�,�n�Ax��vZ	��5,i%aC�w, 'M�U^/�~T��S$i��jy�I�ϋU �{�/�-ףRMQu�.PE��'�㢚�v�W(~8\��o'T=lϷD"��5�8����~Z+��1w�9l[|h��ʗ�d$���(5c�9>I%s2XF�Ӟ}�;���$��,�f0�	�c��$�^�������ǎwQ����΢T4>F�êu��c�;c�� �pTD/�B��!�볶��\��#�`�tˢ���w��	(%&=+�l��:啽�_	�(ʨ��[mJ�w�|��tU���SGup#�p�,"ڧ�ϼ,���>_��G� g柦my\ҋo+�GOe�a+k�_�L��$��V�Ć:���Q\��h$.��[�~�����Ѻ����f�py���1�����Pu�` ���/���������^w`�nUG�t��#�T�1Q�&"rU�7ʋ���b�QD�1@.=ņ��Q B�7fd�d:m%�q]�R��Vڥ�������'ҵX�U}b�wo6B-�Q�p�J����1RQd�hFf3W��s�w{p�E8j2�,+�g�M'[�yܜ.�ƥ����c{|�\(bI�JVXP����>�}�8䏿��/�Ē}"�n^�� �q��f�-6)x��XWQb;��Mi�ʅC9�c�Z�L9��_�[�V�vfR�&~V	����P+2���V�PcF�vPE�%�J�VrD����.�a{�$!�¾cS~gEՠ�
�N|����s�����|K㛴�k��#������u��p��u�I|�����IH�����s���%��4�H���{��z��$Št�{�6���o��T�;O�|��E8;
F����sS�B)�h읯�\�S��� �ِk�)��<��L�\�/2�pb&�9i_���i1"HXU��.��
��V<o#�`�i�"��"����8�� P^�����ް�r��XR�~�9A ��ٷ��M5tx�)bN].\��C �����ׁ�w�ONәS�Mz N�M$�,*��Z`��h&��6���;_Dn����5EO��RХ�4O�P�cM�)�$�QPT�>Q]�$z"�1ND�첶��H�T���'��TDݨ�0m{`��t�yz��o-�S�Db��Ş�/Ac͈����Rd�	[���
Eh �b��p�|1>ob��oBM���C�:�2Ⱥq׋�~ߎC��H�̳E�$�B拻�N;>�`iڷv�Pf^9��^[rx�u�@�i�\�����H�W�a��	Ɲ�q�w�c+'-OVޒY�����Fau���Ql8Y�D�c����[��    L�<�8�az��'��&C��Ye^&��x�&����c���yą�И��Z�xS{E�.M�}�� �1W�-|*#CۏL���9�����=X�`[�^m�L�l�Wk����;��݃��� s�LPe�ʂ~��cm�l����3�2!�ȑ���>Rel��Ҍ��+ }��r��������"t�8�c���Gmi���=��H� ��ؓ�]][�p�Q�Q�?o.	N�S��Ӫ����}�%\H�F&�r�DR�F�=,Ox�r����V�`;�'�>���Հ���e����SHĎ9'[V������ � Lg��������"֤��[�|�21v�/E͛��K��	^�E��p�~smq�V7�(Py�Ón��.bQ� 4,@��aVAb��� a8b��#p��a�pn��$F[����?�$�CB a;��mD�?����ņ���DC����S�gR�6��g��7�YԬ������r��'��#P�IopB\#-p�L0�g�St��Z�P��2����b��XՔ�YL}ět��uG�B*��h�8e��B�z����ڷ�!Zeq�&��t�p(V�TXV$�Cmű?��aߞ)�}� [L���X�nB���xR �[$��iW\����\�j�Z4��C�+��S�ގÉ�X`��5�9_c1��W��zM�@�Ox�p|�I�N���|?F-W�ܴYR�k�6^�O�f�)�x.vȗ`t;X���f	�f0~���:�����vU�=�}����A�~,�c��'*��,�\U�t�Ƌ���)o� ���=)����tt��4?7��b��C*�J�m9-1��(����'K~�juA78� �7ݎ@1+Z��d��%a)j�ɥ4��p�c���a��A�!7W�s>T��`�8���������v���=���E�
�'Sh։؏�
���Uצ=z-n�8�\�]�h�F�Q�B�)�5���NK3���=�P_���;$������g@XY��dƬ��ŋ�:��/hO���W<փ�Ǜ�\�I�t'�l����� �j��`��1�'�t��2�Z)gd�������	�=<�G�p��K.�F���j�эhgn`�p���1��W�ev�04kJ���R����&o{/|d�g���1Z�e����Y�v�aܝ���q�3��	XAL�>>�L7�vݮ;��i����4�"67*H��k[�؀�F�E&��ZWoM̸�TdC�-���N}k�W9�2"��"-��0[2�LL��7��_���K=����� ޳vJ�i�����V�0�"�h���R#�D���	i�}�+e�s [l���~�����*69[&�Q���@*�1!S
�D?�~�=]Jt�"�� �ܤ��� Ğ�p�%�~���	�4�����m������E�79¨hG�~��y�0�	�#�A�.1� �Ƭ�� _{��ow���Q%�9!>׳��fڰ���Vެ����6�rټ�*G� �I��(G�t��UD�oF�b'� �pS�H��E��5Y�*X�s���"8�"o�Gk���(�W��u6k��6�$����� ސ��)�����f0;����V*�s�wj��<�F�e(;��at���+͸I��a�^;�ђd��$��K���UO`1źx��N�'�kq�P),5���Ԁ���C
��|Q&��x��u-"�2)��Փ˙�ex���h'�ͿY7be7��5�8!�q�� ��N�p��vo��Au�Z*?��{�dG��J�iC�p��p����cB���f�
8�V4O�RF�$�U ��%����PR��zɥAi�:��.e���X�����פ�s$�����TKn
�Ⴝ�қu{�c�g����DԳ�
ޚ�B�)�T�����r�¼��[	���W���Y�&���] ��hħ|4��n�[�n"�
������!bu���Soua��eT{�� �� &n�BV�<J w�dqqµS��\���=\��J"&2�:H�&2\4�]U�}6%��D�����&i�����;iGI�r���}s�;vǻ�z�[�CB'PO�b#�چĨ��@se�|!���(9�Ȼ+|�,��V�@6���)�z�;�2�<�D���gԼY��,�+$�j�N��E�6�7�?[S_%��,d��k���� \fT�O3����
n���`we�y��`��[^�'M6&���m�Jh����ޥl�ހ3��폀a��6O���tMq�������K��f!�g٫v湫�+-����0��Q�n���p�>�$����N�a�*�Rn�������T+�,�@&���U�=��:���O��J]k��=�o��v�<� +C(:A�4��y��e��`k g�ݪ���^�Vz�fΧv�sX"��=;j��*p-�qע����3sج|�.��/4h��r`��CT� .�n.IRr2�u�.>��Op��G��ϡ���'$�a��̈́*�t�T � A`��ݼ:�m�$����J2�r�D�hSո����bQq�u7q�5��β����#Dq��{��r1i���O�6�,��q۟������o{�TE��YC�5ݓ��1G�Y;��?��E.��:	::,�lL��Xͷ\l��Re{ ��Ɠ���� 9�4*O�3�3�_��� �kq�C���ȢXל��g�غ�kv�q�͵���uo��Po�e�_r^�ds
\Ը}$:�,�P�y�D��n",�w�t�B1���u[�{�����o�zY�tA"6	����gVN��r#"k��M��%���DPkM%�B���%�^�e-����j-��(m��ކ w��!��)<^*����T��:S��B��cN�w�p�iF��q)�]��V�r8�Ѿ�����ę4�H �����Ͼ=��a^ٗh�D4c-s�S���I(�1��+���h��XE��=��_�w��3��Q��1��0�VO�<��Y�3)�w!�2�x�)��Y�Ӂ:}.T]⺞ϰ�';�4&:N;<�5��ue�O�@h�d`�؝�"a����e�O��R�oz�r�+����D
D$����A�7m�=�XJ�|�dj�;d��a��C��CJ�͍���*��� �����5;Ҝ�+�	#�� *�����
?��}�P@;��Jo;th6��2Z�u��X6vO�'���5RqY�a����$ �^�`5*Z�dB$Y^�;m0��|bf-5�7���Z�h�0�ד��H���6 U}���v7�����/�l�t���U�h*\Èn#��HZϞ������AܢATf�j�n +�yG��TkV�ㄤ����25��ã�~�p&��d2��ϱ�W1z���,ڮ3�?���s����Z�E�H���E�z	��c��"�Ko54���cs�'t��Pn�L��S���e�v��Rj_N�#]�eN��t��LF�i�nX@�������_/J�R���Ѯ�{T��Ʉz�i�_� A�]w�~�XND6(�3��iI��\1_X9�9�R�	�-��XGhe�'����e�����߈Oߤ��.|y��$�Į�F�h�Jw%����zy̤Tꔉu��\ER��G}�zC� T�ԧ�Ӕ=�*�:�V��*�����N'��r���c���i��Pց��vI�kH�)V��ַ��7�<;�t�༦��j����k�Q򥦹˱FY/�gBH5,�^� �x���z/4��X�iu�k9�C�ui.y(��]���Z���H�%���j�شs�hP�uUW�����^�X7u�z�����\�@^-��(�J��I��O�t�<�KZގS�rn� }B����� �S���^�y�n�#6�<QԬruwe�5D����a���:��\#L���my	�K���+ ���]��������j�!cz����d�b� � k�������Tc���6'ѷ�,�:_�:ήB!�vs<�� ��ŝ	�+SP� ��(G����u~1'����/�+��x����y7�I��1�Cg�N��r(�5~-��     ��z$*0~�~�U�V+�Æђ�'���u��vq��I�ߎ��Tu���!&��+��>I�kr)�/9N�(_T�KB$���lE����XX�e�x(���"�P�E���ap>>����X�9:ډ��y�P���w�i�❒;��	�9.�z�E/y%@%�SCXk��C��S��Fiv�������m��K\	��s��/��?�gp�7���u�[7
*��8�$���_��QX��w\~=^�M�;��/D��w~�>\�����c�M4�m�PrD�z��ຎ�T�e~���D��	�S�;�^#Z��`���{4F����'g�h�$�ͭ��_#D���ل��@�a�{��t��?�&Z$"��R�
�YR��NpU�2�Hӽ�*@��3~��׌{�N�p��˓ `����v��8�����ʍ�f�}?¬!�[�M�w����9c���Sjp�g���KG��k9K���6��'?k??�Oi|9����(,`��1�x�uk	���Yg��	�b<�Z���E�K���C���Z���Q�lp���������j�ݾ]�Kh��ݳ���W_����B������,f��7YЉ�+�S��}:T/J\��0���}u�QX�R�q�DrMdr[] ���Z����8���4c�7�m0n� bYY�q	�9\ۍh�k��2��P��=!Nvҟ��*������h�5Q9�Qp����_�s@�|��-�=V&"��r�����,&��<��w�˵���Ґ
 U�V"���1��HN���x��(⏧d;qʕ�z.�~|���O��}����v�Ta�����Q�K�,ʵ^!�����b������[��k�4��w�{��>�͓Q�T��[�ɰ���r����G������	Jx���z�d�]j��J)�Du�ӌZČsGJ*�8F(��C��5�P���]p�&ȎwuQ����Tb{6�Y#�����TQT}jߦȴ�=�~eD.Ru-H�{���89t��YL��g��� �b"��Ju}����}�ӑJ;'�0��aBLO�`�L�Jjl�RC�2E�f��� v�5��+��jl�B� �t_&�6��<��@Qgj�t>z+�O����xRUx��[��̯��
��z��ۭ�9�����D��u)�VuT�l�2���&0JDt6�O�b3.Ɏbs��8⬲O]� ���ӎ(x0�����
�e20�}W��Ujf�G-�!<��b^�bE=r�B�c��6�*_�,�&��Y
�������s�8����?9�� �G�V�cFC��/�V�a������tn���`LQ���O7�x��B�;3S6MM���[��[�;�� �>I��$�/�ؕ���i����g5+p�
`F!�&�؜\�-��f1�I�T��ƪg��ף��y�]�řL����ݍD4��u-��pQ���u�4�	?Փ;��|zC\�$Y��ڮb�ݝ�}'�}�1���9Kg(�;�PW��\�׎������N�ݸ����&��$7~x��+�`E�߰��Z�K{�'Y
�u��A��U4+�7�������9��d=�Q� �B"+Q�yS/�w]������#��+25e��!���������9����`�Y!�$��X��K���.P�K4���48ʪ3�sS�[Jh�c�
������r�)HՔc�Ne"���tr�/����Q��'^C`G�j� ���H�5|�i/����>��7�T��V���r�q���F��DĦ�/s��	����S�.���`��{�W�=���c"C�6�0�A�;;� j�u����/��6�;�%p�#n�����+"]P׀��=8�j��S�
9M$ڈ`�X�q;�|@8DX�134�6
�R�x�$ưa���5�n/�T���;al�Ԣ<�W&`�r���1��58V;)Ho��@w�̈́��/��uP��f-p;!<#ׇLi�!���:1�L�A�<�k��J55���ҳi�;��cS�JP��� �Rw�̀��tN~$1��P�@� {8�8-�����&ۣ��'J�5 $�Q����#}�!v��Ӏ�tj�P`1\G���B�0����	��<�N���ó �\�?O]����h�L���3!'gY��r�K8�F����{jT�eb=M�h+� N�\�^��涓����4|�w��,$��Y�5�!3�?����L��L⍪�6�5.�����pw�ES�9�f����5gkT�ȇ���)�N�jZ�7T&�O�ܠh{�J]�R~�|.�bmQ�F����9��9�����5�a9�S��O�$��c����o�4�x'����~<�[)�o�cO�f����=�	sM���Ŝ�׾�b����Q����]��U�$�"*�D�$�&�������V�_�O����߳V�m0
�����܀Z�f�۟�zQR���>� /�X��Z3�iV��ÿ`��;�}]Gq��/ss}q�p�F��AD��h��.Q��+��e��)��d�Lj6+��*�v�=��oP��$?�N��AEi]����-�>���Q`�v?aBx�F���&�"��RǨF���*D�/j���|����͐�)unp�D�4����R�����}{����Q���?vk��R�*g�;`�Ы�>�h��cbҝ��B��Ef�{&ꄵ:�|� ˀ�Aa~kG�����<��`��,���X���W���>�5A�a�e�yː�;���`��C2�8(#'2�d1R���,p��C�ĕ����^CgEg�ɞ��k�W��S���a��rpI^Q!y�\�������\n���W,�g�r�❗��c,۴G���BmE_� h���Ҙ(����(�:��ҕrPn��|���	����"�V�5�wź>�uAc���c�z!?��8ttB��/W��f��B_�f�Ol���E!��$#>^󈔂V9q���ş��c����#��ؗ��/t�|�U(��W� ,^��
o^���۞��1���׀'�؍�q���D74�>~����+

��O�& 6�5��p����q�VI��'�ڜj�zHe�кX�)�����j`&B"�	�(  ��yNVP.�=�/~h�]�̑�3�*pQ�|d,jS��f]-�}4�����=��|�s$�f����B�36I+��[���^&�L�������K��z�g��	�`t^���o��N��(�l�n`���p�s'��	��:���섦�:�?�������`���I��0CD�fH�:�<�� ������x�b���JM7��z�w �����r����w�c{Ȕ�HjN�)v���ƾ	b�jC7�!��[9U1�

m�fC�ۀ�3"��� X[����t>ޑJ��T|��`d�&׆��/���͋�XFq�JUW�%��-*���)�eK|;4�� �\kSX�ʦh�hR ,�H��d�ʭ�%N���d��LO�w�.�/x������fIx�'[�� j����	�D�,��k0��4�k��;�]WM��U��������g��h�����5�j����|��S� ��i�~�sK^�O���%��2_�h���>;i'cISvL��S�ś_/0�7�:�qǊ9=�iO�T=�>��H�Λ��e=uzK8J�G7�d�
�N�0*Q�s/˅h� ��'EYv��Y�{�Ƴ�1���R�b��V�8���'og�1Q��$�0]o�G;��%�qln�+rL�=8zC�@��e��ٍ���#��B����m"����N�z7�ZB�K�c+�n잇��\��n���HwHw]��j��?{�
��Lb�L�6	�	�I���Z�ZΏ��cz7�YpA�!�	��JՋ+�LՠO�C���3�� �M�Ɋ�Mk��BTE�;���u�[;��Ai��c;lj�EL�e���#����kS�g��h��%\�Z�kR�5�q��{\X߹��^�!�QӠx*"X��@���ӴTm1��wX��gu	9����|�
��:��#"�zc+�AWW���ʭ�9��� Bne��}y.6��s� �  s��غ��f5�'�Ez^��8!�:��"���V�E��࢞��dv P4��,0F����ژD �� �b�0{�[=ݘ�hN��m��O:wH�6����g��0KY��_�Mi��ohhُ�6�:�C���5xI�#������<�f���g������9]�"�ɴ8�f����mJ\��mMl��uK	�2.�˼%�&���F� �Ǻ`�$a�j;,h���3!��l6bY�AJ�cJn�g�Fc�^�Nu�5`���$
Vɺ�ǔ��w���LB_@�oT�`�G��8Jf�MKL���#d��Z�Z"��?��h����~v�����t�@����vP=7S�axW?��O�#l�3���넱�.Kc��wK�<�r!^<����`o�<�������	��;��c�l��1��pB�]�~��+���9�b!G$��v8ِ3����H�ME[��j�b;� I�&6K/$*B���^�^i�W]-�`�+��rD�D����/�Հ�ø;+0|� ��:���p<&f$Vz/ꅄ�L��+J��1~��N�>2g6OS7b�xy>�[l·��-��O�C*33!X���r!�Q@�a�n��mR��M�Ѵ��g�w�!x��:�O��G�o����%L\� ΂�����ƫ)�!��]���RK�G� 推$��{l����U#^&?u4��Z�t�+e4�k{���`G6�IG�+��\��rIVP.�Nx���kJ~���uD�t��I����5�BP��9>\eW��:��T ��^ԕ��}�U5�[�Q,��L6����������� �h���u�g(e,�`��,!vN7rǦi��siq02��KZ�]�Z�qPMU0���Q���O���i�������?4      N      x�=�I��*���/�N������Q�]�$��� 	��������kg>��-���]���~n_ȍ~p�}�Tr���H�:���ޞ{;�ߍ�{~�����9c?�{��d�;�����t 7p�}"ߗ�w̃{TvH;?B� �9���ك\�D���OC����4�i�9x��ܧ��k�>�7ݾp��v������2;��C�R�i�k���&ս���������՞��s^Iƻnb����E�q&�Ȭ���3��s�m���������������w�3���y��}��m�m���,�����7n�X�������j|虦��ة�5I�!�]����O�T�T�#�����{�y��=g�|�r���.R�E��{��c�H��&Zq�Z�_�!���t��o�\�����o��{j�ݜ�n'�ۺ7)�"�|��xj��G�_J��uI˳ۯn�����o�r���t����O5����{2q���n��KH��N�W����wA���������ñ�����B����:���û��z��J�{p�Eݗ�O���q�������Z���_����>�Nܥ�n�sߋy߭���(�]輯$ߏv���������
����Z�����|ق�1n]���L����3�63�IG1��7��{/�צ�g��� ����a\'��Ud���Wp��9�W-�	�X\�k�&?�U�cF�*r��ۃe���k����}�����m���^�RV_���}=PO=��4^� �-�i�t����[��hms�I���������&8G-�u0���s���۸ǐ�UK@�f�c�y�	������g�5ڎb�`�����m�y�&_?˲?w
{�(b�� ɭy�//�ȥ<p�t7M��P����0A;&���{~`|3؁�#��nAD��T@`��)����kB�2���i�s�������w�GY�{p��������af���I�f`��7m��Pd�~�qs�sro��+ɭ|��J�}�W�O��(I�
F��,ॖ��槻q�ז�L|��}
H\[	�}�	��e}��q�Jk��Mw�"�v�?���mF^�r����=��<p��(+��5�q];�b���K�
]�|��"M7�#�yu���6��T����c���$��J�]H\�b�J����^78p��㠏.󈭜דp�^��L0����8}�=8��/��Iv��)�#nD.�x(N���M��#ln��H�@3�zݟ	FSdl�0~��WT��ܯ���@� ��n����x��0�u�� F�?ǖ�u��X9����a������~����Z%a���rF���c܊�5M�RF��t{����Lp��׏��}mWcn�ī/`�і���)��x�у�@�q�5�1��)(����v���y~#%J��"����F{�N�����{aj�a�~� }(�,�����KU#	h�Q��Bw�Z�0M���&p���Mw~���n�u�s���{f�t�+آHM͸�8Uԗ�t\h�FpE$ǈ��鹌���V��[ "����O���/0��Jh���)�=�Ԉ�̘i.����hp�v|7>^zs0�;
��uǿ`���AC
��?un����nJ�j�����.��u���y�#|��<���_�lDd���6��>,��h��1�)�Þ*cPצ#ﶨ��R�������/`��b/�%@=Z��H�vp��(ң�)�Ì��f�����uZp���cn�ҵ��c�И}Z�sf��.����k�73���m�Ԙ�v"ѹTf�IEc���ef<-��0��&�<o��M�V�W�TUe��-T�)_��"��
�{U�QHF��4:Z\���O�mH��T2q�b)�x�G�������&z �Y7�_�,��I�pr�d�����u�f��Mw��&�;��;��|�����:� �����s�4N���>7��u ۘK7���G�p
����B�a��̏iHr&���t睞w�Z��Z�ܣ�޸G4�-���O����=#���o(����Qٕd���s�go޳C$��&�����Ǭ��v��>�t�����L>���q�5��ua�z�-�N(r���rE��\s^�>�Y�2��5=3Ud%n-���ћOP�N��{J��jGϼ��=Ӹ���	�5��G��ʞ\�K����zw�vr�'�̝Mw^�љxx��.�v�^w�s���{� r�1l��5և�d��qD|�� Z�2n7s`�N�:Ot��fJԔ��t.�2���_g�p�/ w{�X�!��y��~U�*�8b�=�Vg���=[.�>0�(V����%��5p|�k8�q.D?�s�-�̝.+��n}9,�髄�w�t��7q7��۱�]��t�.)Dc5�f� (�N���t��b� ��s�m��:g����9�~�V�o�;�NW��~��eU��I�=}�	����\7�f��(���l%i��S�1���͟��2�kpL����a��iӕ�	t�Nr8�ɛn��xO�kY�'C��MЂ��@���$���m�� pz��)���,�۲�d{���A�����8���2�B�n����� ��M�o���t�( q�2<�h��c���޻4~�:A��7�`Yu����܋�:��v�A�F��*̓��E�;c`H����zy`h
���u�`��Ҹ3��'���7��7�,��~����s�����6���S�
z|�1 ܴ��2��8&؟>ZRp�Y_0%������x���l}u����r�sVK���I@;[?к"m+߻�,_�i\ߦ�5+����bt7�D|��T��wd����`��I.Oe0,��~��a�32�ܹ�_6}L�@7���O;�#�b�gܺ*�Ӹ]��9σ�Ny��y@�~�wyW�CF0x�{=�.O��?C�l�Fu�ŗD���L �c� �
O{pLn�˞�Pk��z����C�����A7��[�
�-���]x��q��t���OO�Y��e�?�"���JJ���2]1X+P�u�j�`Bf]�O����"��74G��DwìIٽ�D����`�������v��Np���o+��J��>�O�,�4�4�'5�u��q�� ��� �2�񍂪Y�� qtg`��L!V��m�4�}Um�r�w��p�P��-({ft�����	%w���&n�����s�|��%#�<��>�6�Bt�f��&xuc�ʀW�f�cE|�*����z��S8%�s�>i~@�o�`�T6��/���Q�@n<���;q,�<P��P�^��X��Ɇ�����8���s8�j ��e���և�*8��K�O4��j�+�Y��Y�ƱX����_`�;�c�D5S�ɮ).g'X�ecˈĿ*<�P�V�E�E���x�`�O7O�z-}k+�0m6Ǚ}T�O`܍�;����d�������J�/��-K%�I��d��	s�-�����*��c)�S�n ���$��5b�c�?����GO�����W��v29�b�%�bfO�E�[2�I��^
h&`�3��+��J�i:ƒ3��f��8F9s�`��{�c�u�uR8\K���F<x+��Y't�:�83X`%�Y,H��ٕ�g���8� x�ֿ��Y.c��N��=p�+�VZ
歟��l%g�X�|`��X�R�Q�F�a��LO�18�9�#TvS@�+���t���y��_�o�!0Z�Ʊ�xn��hf6�ʟ�������HDcę%Wp��� R��;";�ir�����Gܥ�D��8�ń5�Ƶ2�]�N���^'���0��	���u��*T6wJ�3[�㢹H�;�Y��]\0W�D.:ݣ�\�	��ڨ߼ì��U�mQ}�����/J����I3SWp��O&%`�+�i�U���X��Z��
(�{��e��;�2yW�ws����>�X9YYhwƱ ��L���7#³Y?[!��a%w�$��|���(e�)�@se�~.I�i�nұ���l@3 (��A`qs�i}���+\e3�X3]���1��X\ �3    ���ү�5��S�+��z] ��9*.�s�	 6g&�9
=�&�N��!��;Ϡ�'C6����d���$�!X��Fz�- ��������:-.M಻���
������V�[��d�t"�V@>�w��6tu��`�@Ֆ����<�7�{=$��q��$�Ȫ��xm>�J22ü�4݌o3H��#�����`Y�۾�l,β⒘�.��W&�+�� ��t��D?Y�C�N�g���uLOM	ӱ#-��(LNf�����4H!Xz\j&��+�Oץ�T�z]���-]N`V�tq/֧=�>�����]�6�Q�G20K! "��z�1\[���5�I������i�T�,G�`Y�k�n����.]�r#Zwv;XY������зhvʺ��@O���pNy��;o�v��I$'�qj��.�z�(V����tV��.��>�%�UZ9�K��tJY����I�p<��N��qt��<��,��@�i0.��ur������u�n*�u��n��b�",�>����8u]7zV��e�����I�v[6Oݎ����������\����GT���<;3Yp�z�L}T�����'0M�1e������;.�w��ϙ���#�W,��F�5�����`ŷ�Ȉj�����'q��H�n���M��1�Q�j� Wլ_�y�P�|j�پ4��0�L�yV0aAl}�5�,��f�RL�T���x�{_�s��^$.�dvw]l�z(���Q�v�`&'�DL�$��I��o�<����{���.��<�4 Os8�@��X�l��t3"vz�MϦ��� q+Z8ͳ�-
�qN⬝��b�m�X�<�8\ħ����8�(�HHG���>wي�n�5Y���ڄ�Y�zXI�͟�Às?)K���Bp���}㱽�Ł7��M"��,?�˩�^� +��5nF%��"ٌ$nZ�� ���B0��˓�;�S�/c���LٟN枸\=�6d'vV��`.�[2��Q��2�߶����a�켊�9��֨H��7Wq�� ��$s0��㸃��Q/��W��9�3�4�Y���eg1�1p���O�t���'e?���u�v\n'k?@�����*���+z���yɝs��ڥ��qBr��;�H휬&�Q��8�;)���}���9��s��
 ^�w~��{�'�sNf���cQ�����ނ(c�Fv����Ȋ6ꄅ�ރ�N
��$�&��wI��cq�G��h����v���E��pi��E��D�G'��hD|K�T��i'h*cg ,��i����A|#�k~��H����՝�䋭��4����)l�Qܥf�
20A��8���抦�3&pMG�q��
^Cw�1�iV:p�����g3��"rUv?��i��~�יVfq�^�e��oj@+|�+�9��=�FA~��%b�xL޻>����7���Us"�M�f|[I�Z��t�{V��c��`�{�q��{�	�-Ớ#(��#�C��<�f8�4�"cG�5�%n��e��1����l��:@�y���g8]]e|"�e�)50���q(�d1��1�[M�Q�(W6�X�8���L�tO�{���3P�B�a���UrusX���-�K ��tc�d���N���Ξ"-χ ��r+�l��������7x�˓��tV�eu��^-�{��W���g`Z$6UNV�s�)��3i��V���d�䳚�Ӵo�O�R��z�s㷻� 	� ���=����h'�%3ֳ]��~h��\q�@YP��=�1�9i����"�;��P�觯��1/�Ղf �e'���~�z��_|�Z�Fh�w]�>��d�yr�]�qt����9;{2�<�~Ke�W���!S�sݢ��:Y�[�����5]�M_|��
�"}�Ǘ��0�UE]I�t`G�W$����r��G0 �d�����7�n��A|+8�� x���10�Z�|�jz?���k)��R�ql~(o��7F�g:����4���`�����Ԍ�^��^[p��@csiP��Ы��f��3��B�3	� 7G�8����q�5�elj������d~��| ��U���v��7��͇�`�����n��I$0�B{��bv']`G�x�+�7���kr�3�'3�"��R7�S10��ٸL�k�N2��	�Ƽ9�x�í�˧-��cvL�C���xx<릗&g|tc@A(�	9eloN�`\n	��4d�͙n�#�3����15_��u]��L�RA7�қ�s�"�S��o�_�b������9�����k����.���Dq��l/\ֈ��|V��>��$��Ǳc�|��W�׍�x6�*c�,E�k��v�v|<���5��7}!E8W �Zو�,���n���b@_w9���m�nN
���X��ָP� O�x����=�pQ��p������q�_�Y7��g���I��E�$0���+�'Eh#��&�;aDxZo��t�r��޼�7�MKzނm��_Û7.���z6p���8��u�N��=�a_}6C�/��V��.�ϯ��C
��,�_�
Y΁��w���u�C�CHl ����Y��i�W���Կ̃�������X��k�
F���頋���>�"�|�Kn���3�_�tSɬ�M��)%��3�a�g����}��&E���g����/~W��G�pOC>��qzXХ�	��(�_q�+J��_ް�ù�+W��?"����%~zsZ�D���sD�r�*���*�|�gd��]����ωTYr��gD?K\��ħF�������{�=!1!�l����"��#��҂��c�q�[���3z�J>~��붸����_�e�^��Y��|rO��)����/�w���9��C~l���K�/��n����4��PZ������+�Q�|�J�v��W<	O���rw����[0�`R���|	��^�K�b
��ԼɏC�,J����ֈ�첗�<�,�[�.N��r%�����y��f���c<���_z�s�SbxK��~�ȳ�$o����(��~'�6A�7pՃ_1kmW� ˯�dK�&R~eS��M��E���ߊ�
�9+���;���/g�a�wş���\��}�?w/{򤼧��������S�҇��v���y�9���-�_��o���+�K�V���\?�/�Q�F�>M��9��+�g�;�rf��p�����b�k����O���ۙ����_�Ź�}G�Ro�{���%���������Z�j���P�9��m��W���[��N���1�ܕ�nѳ{��(���qiP�VL�m)o��S��nZ�J���h%���U ��'�c���z��E۪���uk�q=�-g�9"S�SzN��Y�8���x�����
gh���+"ׯx%�&��G͆��'���dS�I�*����I-w1 TMp	��/�F$7�`*�)y"�I�0J��]<�w`g��J�*�.�ȯʟy���K؊��Zw�Zy��a���%����=+3cegL�b_X����r�N1oes*ǈ��7��a���cp&6����ώ��gk�a���h���X՗�
a��bl
��/&L���z�:}��V�^W�]�y��*Z�4��];������lo�֋�ϳ�I�ً7�8'W�_��zΧ/��
:�ь�����G9b=�bھ.TA-�Ʉ�n�i9,��9������8R����R�*��pG����\����:�X��~���X�XQf�{�'��ݗyrU�.��kN���<�`��O��F�aU^�5�%^�b_��>�m��1��I-?u�-�����቎�K���Ďf�o�g��Ziá��Ү�#���5��c���kr1���'X���N��e�r�A�(i�ۏ>m�%\�}�������g؎n�R��gV�����J�{����r��Ϯrj��q\)w��8[b3�º}Rg9!�i�,�i$��B���d�j�Jn#�S��	m쎫]rF���oW����sNl���5�m.��m�	��j�N�e=�_��9Ex�,u1���L    ���ae#���/y�n}��=̛9
��/����<����w>g�Wx�Ϻ��-�h�l���~�_㙵.[��/�X>U���-���H���Ǡ�W��dK��ei9�/�(�<l�Kÿ�4�������rTC���dA��$��R��������T,��įʗ��r%?е�24�6�S�Zb�W���b�G�2K���&�yV�s�a��J���gSip�d�Z⭁�� -߼[�/��-c��c���+�2��2�&GdlZLX�I�xӈkI�+\�juV;i�X�½�=K��N�E�+-�)�<IK��&O���|9�/o�Q�T�5���M
���w���CߎQW5<&�Q,�U:�-�KrD.�q�+�ZZ��S��aI���<��R>�
x"�8�L�!�2;�^M?=�j�W��5��?#�[�{�k�]&;�V&O[�\�KϨR�Y\����([�R�pU��ߎQmI��VP[�1�b�틹6�-wo	��0�n���⍆��<���ɪ��XY��+�%�/�<�Z�ј[�]�=b���/�?-�G�&�%Th���1�'�]S�4�(�~Z1jݡh5iُ�;\��Ϫ|s���
�HzW��`[��*��ő����V��������hS��/ᩛǓ��Wx��8[>ɇNR[�L�'�.�B��I/����f��9�n���j��m3�����b��V�܏��^F����D/\	γ�Qi͸�ε|�/W3�ôXԑ3zƎߥ.m�%ݪ|�H�Sq�y����lU��3��u��:��N��V�5�&4n����	��7����L�����I��R�K�N�Y���¿�n�]����BR������^�ס��=�4��~�p�Gcr[�灭�
w��ѸVL��c��I�m4��i��K� o�V�Nba�+��c����\ҝ=�
��[�oA.�B-���L�2��2oY��Ҝ��[f�ښ�<����a����ۥ���w�t[��O��.���������~�.�?.i�G�{����Ըz��Y��F�M��YL�#<I�o����Y%oc���_�q*?;lX�n]��p,���7}d8�	;�EM��Ъ3��5�9�E���N��	�,�3��b፾S�i�_n�F����o�t
0wO� ��wP��}��#(�}�f��ˤ��u/��̦k/y�9ע��y��1u���F/�_��}�q 2&���Ux�7�x�F�5.��LQ��w�Nz�2�D�ݼƑ;��*9G��$_����[��{�b�uu�Da�N�B�\r��У��4�]?A�3��G�_���z3v~7�笋<��@�\���QX�4ԏѼ
��}�o�|Z�k�O}�Z9v�t�_'���*?���c<Y��(����ש���-b�U��K�;�dӢ��^�=�*Z��p'��x�IZ��>-�	_��.ϟ57q� o���]�ր�ډl����&l���d�w��H>��6K�?��k���A�<�rhm/��_�y�n�e�O�������и�7����x��Nį~�RkF/��@�R�7�n1��pGs���s���5ȗt��W�~�a;z1�%����6�Z��C
-��G#y�y���>��=�"fcg���V��_60G�� �I.��8����H:�y�>� F��"_���s*��Zl������6WW�)�yi^፿���V�I�7��Վ���t�����������HH�:�2ouFc��O������F�O��*[FO��K��E���v'm�ۋ�Y4U�_C��?�b��!Z�"o��6��g���q�a�_�#o�
���Urn�Ȥ�����U�N���{��sf#�w�-y�h�XG.>�5��M�:�&o�D��yz�rjW��7��a�;��&�?H�Y�_��j,b�׋�%��p�G��/�K,��s";4� �_�6b֯�̴�XO��g�ä˓��c7��g����`t��b�;_�/4j�����|��.�$Ԩ32cV6���`�^��ZO�����음UMZ����[j|�r�W������w�1b�8�rV�f����r�қ}�\F�<�4aKk{�g��	�*"�F7�V����0��Gm$i�+&Y���x�)G�f��po��?�卞ܔ�W�ҏ*�[�eKQV��AŪ�Hy�[I�B7�F�`������ʈ	�����O�-�u����G�W�sVxz�S-��������x!�VߜT�"b/V�*�?��^�]$����sLz+�j�I�^	wG���b�R�_��"�0b⯽��r�1���
�Y���
N���R��%M�1b�+�D�W�]��7=r�����ku���GR�4�xÒ�w����p��o�����5���a���v��������o}�ڂt2������B���,���s��3����
w 1�9��n�J�/M;���2c
������a�����(���X��5����W�rZ�}��|'�Q����y4C��?�X���g�#��-�M�S�!��`�pw�g�C����v�*r��ƉVz�R����pl����Y�>��WhU1�r�;�[|ތ�a�6m; }���d��䣸B��Ȳ2���;��	-����a�s:5k�E�ћ�3����
wЉ�ř����L��[x�bΪB3��П~�~�'��pZ�YGKd��([�����!o��t�����83����ǟu�V9ܦ�nL!華�Jл���-Dm��97}����c�h͌5䯬?��wD�Ļy��I_���oMBF�m�2��'��b��+��қ���F�?ik���d���Kor�3����L�����(8���ڿ�u\U���/r��Õ���;���/����s+�s����b��	�ӓf�/���K��9�9�]<�	�`��nO��'���G
�I:�M���[�'k�X{��=9"3�e��bǾ�\%����o���ͽ8�V�3�of�+�M8љ�`8��xB{�[=����f�X�p���h��>�|�$w���ܜ���?%�'}�zw�u)���`�Q�_l�va#����_>�*�J���/;��2`r��T3��ۥg���q�?��I�|���4
.3�?��k��
�!��pE����MC�/��j3r���/r�4z�5CX�]L_u�������ʇǲ��mת�����_qI�8 ��F�
9��$��\��]�V��2�֮�o�EZ+�t~s Kޟ�\1�%g�y΂�F�n��M��O�+�=���F�VI�O��m����J�5�'G��:��y���ٮ�������L��9�����I���1��"4"���B�Uɯ�J~Z��Z��e��NO�9H�f�/~Wˢd�|1C,O����3��C��ōOK�©Ӫ��ڛ�^��E_�4XV:�>�6U{�I���KM�Yc�*d��c�3�����t�R�ފI�g2�+�Z�$>�8�D�bP�.mr�dՕ��}[5LШd��i˞d���i��S�Z�2����=��^�����6 ����ɝ��Kd��������s��8o��jR�ֶ�',�.��]��[?b���kW�~��n��q �����ݯ�&���|Q�?�7��p�g_�{��Tٯ�#��Tk����ӛC��ߒ�mVMHF�i:�"�ۧ�ة��d3	���;u=iaO~����*�P���ת^��:��-�B�;����U7_o����;�W�;^[�+���WY1�%�X~)�.&�S�n�R��K�Ǟ������lS�r�!u��ƿ�����7�s�3�=��keA�Q����.v���9ӎ=y{��ϳ#�>[��H;�c�K���_�~yB�/wԍ"�1,}��q�]&�h�>�	��K�.���<�ǵ�]2z��Tۙ���c$Z�s�-�fle�t�`\��,�3[Ը�o�e�`����	�ʾ���Q�2�߮�]kf3z< ��͞||�v�S��ڶ֤����/{�:�4(;���{ޱ����,�_1zrm=g�5���\�F�*���˝b�V��!�����+pe�7�j9�
g�R� ����@�X}����V����M�]�Uvq��??N>2�����k��-�N��K���*���+���� %  %���L�\��Tm��V���:$���˿;?����S�pp�.��{��r#�m2�V�U�j���69�w|�k�a׹��ߎ���3�ƊV|~5~i�GV�~�Fi����_��|a�>�Jjó�M�� ��� ��Dv�y�v�A;]1<I�r-~~a/�<�����ϒO��sbH�K���aױP��\��QA�HBÝ�n���XO���2���2M{}���τ��)Z�,��-�]_���B��|�[ź;��eh���`V�5�)r�^9�o�&�&���ί"�U~��:��o�;7�ϝ��7~�TeJ�z���U��ݺ�[�+�01�i�Sp�N}i��:��O��x���U	Lvrʞgy��ňg��Y�S���`�/��ɤs�s�&�	w�r�������q"�q?�Y7T ���>��+�?��݋7l�̙��@��è��L~n8h����v���]ɓ	w�q�X.�[u9�U��Œ���V9n]���>�n(���,h{�o��wV2��V~/�e�ԸZ��^NV��?�%[�y�����S�I����s��M����5��G�!y�J�'�Z���s��\�.�����<�W�^,tNa�i�N�(`��[��&�;~��p���R'�P�7��҆篘t�pE��7�<G�팵�=�l��9SN�e�W��F#��7�>`�sşש��i��]�S��L:<`�������v�v-4���|W��pWY��4�}�O3�o��2�w��-K��g�2c�:煭��>xY����<�	��+k�'������}\U�V��;Y\8Y\ W��x�%�H�}�Y���g�����IPU%�=r��{T�'�#���o��G�v4ή�>(�Ud�h1�
]�ٕ�G��9W"�����_0��l�W��$����������lI�q���~#zN�q5��-����Ur����{1�u�G�8х�	��v��+����l�ʝp��@��[�E}�zb#-,��<�[/ԭ��f�V��]#rN/`��ݑS� 0UJ룅QAu�1����-�*{�=��FD��)���F2܄����z���E��̭�Wo� �S:Ւ�ב�\U��oK���%z|�<�%�҅h&�����eq��@��W �&��,�[=��9o�C�#�d�S�:ֆ�WŮ�����+��Ί��-K�2к�+܉��5�O���eq����a�+�a�O�9�[�W��VY=���w������L|i�г�s�rk|�%Saꮝ�0�_Iy� ��;��**���LJZ���r��� ܥ׮�lwؒ>Ϭg���g%�L��c$T����8�N�?��D�1�[���.]N�=:r!�uY�F���L��߷k��r�I+<�@-0�^~o�̼Bk�Gzx������L�yGh����䝨��b�ܽ��'`aO��%x��|0g*+����#�4:�����>T|�	<�s�AS��Jw�����\ފU��r�YF�3[�S��	�>?���iŻJ'���V��K�5; }�~Rr3ܸ���>j�c�� zov��j�b�}4;ܷ,z�U����hի�xo�o�Z�z��ַ%��ɽ���3�:��{#���<n�U���D��KzJE�'~b���`��{��J�\<�-��7c�~�[��h�=UC��r�5�����&�ܽS-ѩ�tb���U�������,��M�[�)�vm)�ߴi��7��M�ysh��"	�_}7Ij��K�_���[��ͨ��a�[f�P����a�U�U<�������闬hf�J��v����u�w'<�H83X��I���r$=��|������������      O   <
  x�-�[�,�
D�W5�Ty�������+SE��_���9�7���_��/��W�h5��;�;g�|��m�;�^ɜd�������~�G���:�鈿c�����,y%�>T:��C�=���L�rV%��4�i�ڴW3ڛ�c9�徟��j�7���7����~g�%�ƻ����<5�׬�=����qF���
�+F蛑��V
V�o�N�+%��NVJ��<��M�1{f,)XG�գ�*�@��SH
V�����i����!���F��G��욅�����,�33�C��i��##;-�<_���J�����չ�#��E��,�a�����i4���mp3]��];3��}ѱ����l�,�L�}�G?oAk�R���Ϡ�/jz�sIz�F7�Y��4B�|t%�(`B�q�8vR�z������J�%ㅂ�B09"Ϡkv���H��08�ʎ`6/�	�d���h���X;��۬�k����vJ�>�+�����S8|�����=���Nk�x�Qs����Vz�o��o��:�;�I�'����ֻ������&	<���WL5-'w�U�J�{�+�i����{
IV��Y���������o>�;��	}��u}3y]�o������;���t|�5���^0�-qrzw��V�{-+�߈9�fB� ߴ�J߈{��^�ɬ��L"�o��z����q� �=7᝛�>����{~����D���>���֞a1A��[k�Z��fBAp��(�<�5_c��=�c�8oo�iE�۵/�����Ç��A>�pZ!�}8�[|_����}2�;��4߁�ކ�wD�8��G���,�Ŏ�����}�c��
	��i���Q����������J��'OzO����[�*`bҧ������ς�5� Q]��sp�|M�k�����;�{�L0���~��ዕ��?`�_��^�b/��5`
G�\�%���3"Gz)��������*Pk���+X���H~�&hR�V$x�T��j�h��w�*
'I�Hi>e6��>�u��m!hA�Ծ(�@p>;;���ѥ@nO4r7N+�����a��] lW�3°��C�a��o!؛}	��ͷ�у�s R{2��U���f2��X��ɡ��wcq���0�Y�mVg��7�|��Μӳ���Q��=���>X>D�伶,ha���(�=���`Ѱ��Y�q#[Bö,h�Y1I��l��	�V����f��`�i���������6�3b�����5�o��7صf���[�;I����w��� 쟖w!O��z��h�N�G��!
�A� ��b���@�_\ǯ��|�1��g��Kq��W9��:����{�(��-#����B��q��F��`�M��������[O�)�sw��7e%�aw9��<�]��.�p_iO���}+� vx�?�����
D�&������u=�<���C}.�M��Z?Q?Q�@���D%��z�"/�@^�E%�x	�^Mu��qz��M�sR@o���/z�zs��QƇ����Ƃ�����~��Ph}Į8:�8�"���/9LŞ8�@��[Q_,�b�W���
>qW���S��}qk%�jPY`<�WlO��Ϸ��A���$`��CH��?̷��a���@P�����A��`K�p<(\�Gl��
hJ�"؀�����` E�B����H�o$�;�_l[�F�P`
��@��	jwP;C��p�0
Z�F_^��0���z(�[it4EL~P~g_(�x���i�)�V�I��/%`y�<Z�.g�LBo. s����`n!�w/�q� ��e�Mz����o'�N!pڷ#�݃8��O>�3���� �p��]��~�2$M�K���E`nN!pZ��W�e������tL�����/�89|�ʇbXn��3lģ	3��$'L��LE���\�d�t�D�$���[�$�.��_��>�@��K�^ڔX ��%��l�@�X8)�S48�т���W��A��`-�'�08��B�v@$VP��������,Z���*��LPG�#�	4XB��]�P����I��xv�a���**��-�j�����͕�P��z���0@=n�Ϋ��+#
����,	����	�� ���7`�`Q��\���|-�ܟy�*x�"��
0P!�xۧ��yQE���*A~�k���L�i`�+�D�8Q宿i`�ΐ{�ETQW1�� U�#��`P� X�<��L��,H�z7��p5��c�p#q���&��p���^�b�?�`A+��
 �G.�䁽Ep���<��\6�M�ȇ��ýD�K��D�W^�.��3���eR������M�o5xđ�X����*�lÆ�ׁm:�6�y��&4�˽�H�n��˷sK2�."m��mh�7lGl�;H�8� �i�ponʐ�"��i�㝬�Ho"؉깋sع�'��!M�E"�{�b�i��)����4������T�'���[�^��f˃���Cs��}�������?d�J      W      x�3�4�Գ4�2�4�1z\\\ &@     