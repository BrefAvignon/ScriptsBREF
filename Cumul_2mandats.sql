CREATE OR REPLACE FUNCTION "BREF"."Cumul_2mandats"(
	)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
DECLARE
	mandat character varying;
	annee integer; 
	nbm integer;
	arr varchar[] := array['CONSEILLER EPCI', 'CONSEILLER MUNICIPAL', 'CONSEILLER DEPARTEMENTAL', 'CONSEILLER REGIONAL', 'DEPUTE', 'SENATEUR', 'REPRESENTANT AU PARLEMENT EUROPEEN'];
	listemandatscumuls varchar array;
	count_liste int; 
	man1 varchar;
	man2 varchar;
	man varchar;
	mindate1 date;
	mindate2 date;
	maxdate1 date;
	maxdate2 date;
	minannee int;
	maxannee int;
	nb int;
	i int;
	ok bool;
	okliste bool;
BEGIN

	CREATE table  IF NOT EXISTS "BREF".cumul_mandats(mandat_c character varying, annee_c integer, nbm_c integer);

	--deux mandats cumulés
	count_liste := 0;
	foreach man1 in array arr
	loop
		foreach man2 in array arr
		loop
			if man1 != man2 
			then 
				-- conseiller epci/CM n'est pas un cumul mais une obligation
				if (man1='CONSEILLER EPCI'and man2='CONSEILLER MUNICIPAL') or (man1='CONSEILLER MUNICIPAL'and man2='CONSEILLER EPCI')
				then
					--on ne fait rien
				else
					man = man1 || '/' || man2;

					--on cherche l'année à partir de laquelle et jusqu'à laquelle on cherche le cumul
					select min("DateDebutMandat"), max("DateFinMandat")
					into mindate1, maxdate1
					from "BREF"."Mandat"
					where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
																		 where "TypeMandat" = man1);
					select min("DateDebutMandat"), max("DateFinMandat")
					into mindate2, maxdate2
					from "BREF"."Mandat"
					where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
																		 where "TypeMandat" = man2);
					if mindate1 > mindate2 then
						if date_part('month', mindate1) = 1 then minannee = date_part('year', mindate1);
						else minannee = date_part('year', mindate1)+1;
						end if;
					else
						if date_part('month', mindate2) = 1 then minannee = date_part('year', mindate2);
						else minannee = date_part('year', mindate2)+1;
						end if;
					end if;

					if maxdate1 < maxdate2 then
						if date_part('month', maxdate1) = 1 then maxannee = date_part('year', maxdate1)-1;
						else maxannee = date_part('year', maxdate1);
						end if;
					else
						if date_part('month', maxdate2) = 1 then maxannee = date_part('year', maxdate2)-1;
						else maxannee = date_part('year', maxdate2);
						end if;
					end if;

					--pour toutes les années possibles de cumul
					for i in minannee..maxannee loop
						nb = 0;
						select into nb count(A."IdIndividu") from
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man1)))
						and "DateDebutMandat" < to_date('01/02/'||i, 'DD/MM/YYYY') and ("DateFinMandat" > to_date('01/02/'||i, 'DD/MM/YYYY') or "DateFinMandat" is null)
						) A
						inner join
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man2)))
						and "DateDebutMandat" < to_date('01/02/'||i, 'DD/MM/YYYY') and ("DateFinMandat" > to_date('01/02/'||i, 'DD/MM/YYYY') or "DateFinMandat" is null)
						) B
						on A."IdIndividu" = B."IdIndividu";

						--si il y a bien un cumul on cherche si on a pas déjà enregistré ce type de cumul, sinon on l'enregistre
						if nb != 0 then 
							raise notice 'count_liste %', count_liste;
							ok := true;
							--if (count_liste >= 1 and listemandatscumuls[count_liste] != man2 || '/' || man1)then
							if (count_liste >= 1)then
								for i in 1..count_liste 
								loop
									raise notice 'on rentre liste[%] : %', i, listemandatscumuls[i];
									raise notice '%', man2 || '/' || man1;
									if listemandatscumuls[i] = man2 || '/' || man1 then
										raise notice 'false % - %', listemandatscumuls[i], man2 || '/' || man1;
										ok := false;
										exit;
									end if;
								end loop;
							end if;

							if ok = true then

								if(count_liste = 0) then
									count_liste := 1;
									listemandatscumuls[count_liste] := man;
								else
									raise notice 'listemandatscumuls[%] %',i, listemandatscumuls;
									raise notice 'man %', man;

									--si l'association de mandat en cours n'est pas encore dans la liste, on l'ajoute
									okliste := true;

									for i in 1..count_liste 
									loop
										if listemandatscumuls[i] = man then
											okliste := false;
											raise notice 'okliste false';
											exit;
										end if;
									end loop;

									if okliste = true then
										count_liste := count_liste+1;
										listemandatscumuls[count_liste] := man;
									end if;
								end if;

								mandat := man;
								annee := i;
								nbM := nb;

								--return next;
								insert into "BREF".cumul_mandats(mandat_c, annee_c, nbM_c) values (mandat, annee, nbM);
							end if;
						end if;
					end loop;
				end if;
			end if;
		end loop;
end loop;
return 1;
END;
$BODY$;
