CREATE OR REPLACE FUNCTION "BREF"."CumulDepSen2017"(
	)
    RETURNS TABLE(dateelec date, indiv character varying, mandat character varying, datedebutmandat date, nuancepolitique character varying, nomterritoire character varying, typeterritoire character varying, idterritoire character varying, codeterritoire character varying, nom character varying, prenom character varying, sexe character, datenaissance date) 
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
    ROWS 2000

AS $BODY$
DECLARE
	arr varchar[] := array['CONSEILLER EPCI', 'CONSEILLER MUNICIPAL', 'CONSEILLER DEPARTEMENTAL', 'CONSEILLER REGIONAL', 'DEPUTE', 'SENATEUR', 'REPRESENTANT AU PARLEMENT EUROPEEN'];
	arrdatedep date[] := array['01/02/2017', '01/09/2017', '01/09/2020', '01/09/2021', '01/09/2022'];
	arrdatesen date[] := array['01/02/2017', '01/09/2017', '01/10/2020', '01/09/2021'];
	rec record;
	rec2 record;
	man1 varchar;
	man2 varchar;
	man varchar;
	datedep date;
	datesen date;
BEGIN

	--deputé
	man1 = 'DEPUTE';
	foreach man2 in array arr
	loop
		if man1 != man2 then 

			man = man1 || '/' || man2;

			foreach datedep in array arrdatedep
			loop
				for rec in
					select A."IdIndividu" from
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man1)))
						and "DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
						) A
					inner join
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man2)))
						and "DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
						) B
					on A."IdIndividu" = B."IdIndividu"
				loop
					for rec2 in
						select "NomDeNaissance", "Prenom", "Sexe", "DateNaissance", "TypeMandat"."TypeMandat", 
						"DateDebutMandat", "NuancePolitique"."NuancePolitique", 
						"Territoire"."NomTerritoire", "Territoire"."IdTerritoire", "Territoire"."TypeTerritoire", "Territoire"."CodeTerritoire"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						join "BREF"."TypeMandat" on "TypeMandat"."IdTypeMandat" = "Mandat"."TypeDuMandat_IdTypeMandat"
						join "BREF"."NuancePolitique" on "NuancePolitique". "IdNuancePolitique" = "Mandat"."IdNuancePolitique"
						join "BREF"."Territoire" on "Territoire"."IdTerritoire" = "Mandat"."Territoire_IdTerritoire"
						where "Individu"."IdIndividu" = rec."IdIndividu"
						and "Mandat"."DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
					loop
						dateelec := datedep;
						mandat := rec2."TypeMandat";
						datedebutmandat := rec2."DateDebutMandat";
						nuancepolitique := rec2."NuancePolitique";
						nomterritoire := rec2."NomTerritoire";
						idterritoire := rec2."IdTerritoire";
						typeterritoire := rec2."TypeTerritoire";
						codeterritoire := rec2."CodeTerritoire";
						indiv := rec."IdIndividu";
						nom := rec2."NomDeNaissance";
						prenom := rec2."Prenom";
						sexe := rec2."Sexe";
						datenaissance := rec2."DateNaissance";
						return next;	
					end loop;
				end loop;
			end loop;
		end if;
	end loop;

	--sénateur
	man1 = 'SENATEUR';
	foreach man2 in array arr
	loop
		if man1 != man2 then 

			man = man1 || '/' || man2;

			foreach datedep in array arrdatedep
			loop
				for rec in
					select A."IdIndividu" from
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man1)))
						and "DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
						) A
					inner join
						(select "Individu"."IdIndividu"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						where "BREF"."Mandat"."TypeDuMandat_IdTypeMandat" = (select "IdTypeMandat" from "BREF"."TypeMandat"
							where "TypeMandat" = upper(unaccent(man2)))
						and "DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
						) B
					on A."IdIndividu" = B."IdIndividu"
				loop
					for rec2 in
						select "NomDeNaissance", "Prenom", "Sexe", "DateNaissance", "TypeMandat"."TypeMandat", 
						"DateDebutMandat", "NuancePolitique"."NuancePolitique", 
						"Territoire"."NomTerritoire", "Territoire"."IdTerritoire", "Territoire"."TypeTerritoire", "Territoire"."CodeTerritoire"
						from "BREF"."Mandat"
						join "BREF"."Individu" on "Individu"."IdIndividu" = "Mandat"."Elu_IdIndividu"
						join "BREF"."TypeMandat" on "TypeMandat"."IdTypeMandat" = "Mandat"."TypeDuMandat_IdTypeMandat"
						join "BREF"."NuancePolitique" on "NuancePolitique". "IdNuancePolitique" = "Mandat"."IdNuancePolitique"
						join "BREF"."Territoire" on "Territoire"."IdTerritoire" = "Mandat"."Territoire_IdTerritoire"
						where "Individu"."IdIndividu" = rec."IdIndividu"
						and "Mandat"."DateDebutMandat" < datedep and ("DateFinMandat" > datedep or "DateFinMandat" is null)
					loop
						dateelec := datedep;
						mandat := rec2."TypeMandat";
						datedebutmandat := rec2."DateDebutMandat";
						nuancepolitique := rec2."NuancePolitique";
						nomterritoire := rec2."NomTerritoire";
						idterritoire := rec2."IdTerritoire";
						typeterritoire := rec2."TypeTerritoire";
						codeterritoire := rec2."CodeTerritoire";
						indiv := rec."IdIndividu";
						nom := rec2."NomDeNaissance";
						prenom := rec2."Prenom";
						sexe := rec2."Sexe";
						datenaissance := rec2."DateNaissance";
						return next;	
					end loop;
				end loop;
			end loop;
		end if;
	end loop;							  
								 
END;
$BODY$;