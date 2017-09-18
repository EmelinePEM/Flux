unit uFM_Coup_Rlx; // PEM

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uClasse_FM, uTraceDebug ;

type
  TFCoupure_Rlx = class(TClasse_Flux_Matiere)
    procedure FormCreate(Sender: TObject);
  private
    Flignes : TStringList;
    FTag : integer;
    Rouleau : integer;
    Qte_Corrigee : real;
    Mouv_Roul_Stat_Num_A_Corriger : string;
    MOUV_ROUL_Date_Debu, MOUV_ROUL_Heur_Debu, PHAS_PROD_Nume_Ordr,
    PHAS_PROD_Num, PHAS_PROD_Num_OF, MOUV_ROUL_Num : string;
    ROULEAUX_Nume_Exte, ROULEAUX_Nume_Pale, PALETTE_Unite : string;
    MOUV_ROUL_Nume_Phas_Prod, MOUV_ROUL_COTE : string;
    SOUS_TYPE_STAT_Libelle, SOUS_TYPE_STAT_Code : string;
    TYPE_STAT_Libelle, TYPE_STAT_Code : string;
    Statut_Roul, Statut_Qte_Roul : integer;
    Qte_Roul : string;
    PHAS_PROD_Num_L0 : string;
    //Num_PV : integer;
    Nb_Balisages : integer;
    MOUV_ROUL_Num_PREMIER : string;
    A5, A6, D3, H3 : string;
    ROULEAUX_Nume_Exte_BIS, ROULEAUX_Num_BIS, MOUV_ROUL_Num_BIS, ROULEAUX_ORIG_MERE : string;
    MOUV_ROUL_Date_Fin, MOUV_ROUL_Heur_Fin, MOUV_ROUL_STAT_Quantite :string;
    Unite_saisie : string;
    New_Qte : real;
    New_Qte_Str: string;
    Code_Unite, Qte_Calculee_Str, Qte_Mesuree_Str, Qte_Mesuree_Affichage : string;
    Qte_Calculee, Qte_Mesuree : real;
    Conv_Unit_Refe, Poids_Au_Metre, Nb_Pas, Nomb_Piec_Pas : real;
    ToucheUser : Boolean;
    Recopier_CTRL : Boolean;
    VaRecopier : Boolean;
    Qte_Reelle : string;
    Arrondir : Boolean;
    Arrondi : integer;
    procedure Initialisation;
  public
    constructor Create(aOwner : TComponent; Trace : Boolean); override;
    procedure Execute0; override;
    procedure Execute1; override;   
    procedure ExecuteC; override;
    procedure ExecuteV; override;
    procedure ExecuteA; override;
    procedure InputOK; override;
  end;

var
  FCoupure_Rlx: TFCoupure_Rlx;

Const
  INIT = 0;
  ROULEAU_SAISI = 1;
  QST_PHASE = 2;
  PHASE_OK = 3;
  QST_STATUT = 4;
  STATUT = 5;
  //PV = 6;
  STATUT_QTE = 7;
  QTE = 8;
  QTE_OK = 23;
  //NON_CONFORME = 9;
  FIN_SAISIE_OK = 9;
  SAISIE_BALISAGES = 10;
  ROULEAU_CREE = 11;
  RECOPIE_CONTROLES_FS = 12;
  CREATION_ROULEAU = 16;
  ROULEAU_BIS_ZONE_ROUGE = 18;
  ATTENTE_NUM_EXTE_BIS = 19;
  NUM_EXTE_BIS_SAISI = 20;
  SAISIE_OK = 21;
  FIN_SAISIE_ANNULEE = 22;
  CONFIRMATION_SAISIE_NC = 23;


implementation

{$R *.dfm}

(*----------------------------------------------------------------------------*)
constructor TFCoupure_Rlx.Create(aOwner : TComponent; Trace : Boolean);
begin
  Flignes :=TStringList.Create;
  Inherited Create(aOwner, Trace);
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.FormCreate(Sender: TObject);
begin
  Initialisation;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.Initialisation;
begin
  // Init Var
  A5:='A';
  A6:='A';
  Rouleau:=0;
  MOUV_ROUL_Date_Debu:='';
  MOUV_ROUL_Heur_Debu:='';
  PHAS_PROD_Nume_Ordr:='';
  PHAS_PROD_Num:='';
  PHAS_PROD_Num_OF:='';
  MOUV_ROUL_Num:='';
  ROULEAUX_Nume_Exte:='';
  ROULEAUX_Nume_Pale:='';
  PALETTE_Unite:='';
  MOUV_ROUL_Nume_Phas_Prod:='';
  SOUS_TYPE_STAT_Libelle:='';
  SOUS_TYPE_STAT_Code:='';
  TYPE_STAT_Libelle:='';
  TYPE_STAT_Code:='';
  Statut_Roul:=0;
  Statut_Qte_Roul:=0;
  Qte_Roul:='0';
  //Num_PV:=0;
  Nb_Balisages:=0;
  MOUV_ROUL_Num_PREMIER:='';
  D3:='';
  H3:='';
  ROULEAUX_Nume_Exte_BIS:='';
  ROULEAUX_Num_BIS:='';
  MOUV_ROUL_Num_BIS:='';
  MOUV_ROUL_Date_Fin:='';
  MOUV_ROUL_Heur_Fin:='';
  MOUV_ROUL_STAT_Quantite:='';
  New_Qte:=0;
  New_Qte_Str:='';
  PHAS_PROD_Num_L0:='';
  
  ToucheUser:=True;

  Flignes.Clear;
  Flignes.Add('**** COUPURE ROULEAU ****');
  Flignes.Add('****   SUR MACHINE   ****');
  Flignes.Add('');
  Flignes.Add('QUIT <ECHAP>     SUITE <ENTREE>');
  EcritMemo(Flignes);
  FTag:=INIT;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.Execute0;
begin
  if not ToucheUser then // si l'utilisateur presse touche pendant traitement...
    exit;
  Case FTag of
    QST_PHASE :
      begin
        //Meme_Phase:=False;
        A6:='PH-1';
        FTag:=PHASE_OK;
        InputOK;
      end;
    //BALISAGE :
    //FIN_SAISIE_OK :
    SAISIE_OK :
      begin
        FTag:=RECOPIE_CONTROLES_FS;
        Recopier_CTRL:=False;
        InputOK;
      end;
    ROULEAU_BIS_ZONE_ROUGE :
      begin
        // le bis n'est pas non conforme : on ne fait rien
        FTag:=ROULEAU_CREE;
        Application.ProcessMessages;
        InputOK;
      end;
  end;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.Execute1;
begin
  if not ToucheUser then // si l'utilisateur presse touche pendant traitement...
    exit;
  Case FTag of
    QST_PHASE :
      begin
        //Meme_Phase:=True;
        A6:='ME-PH'; // Meme phase de prod
        FTag:=PHASE_OK;
        InputOK;
      end;
    //BALISAGE :
    //FIN_SAISIE_OK :
    SAISIE_OK :
      begin
        FTag:=RECOPIE_CONTROLES_FS;
        Recopier_CTRL:=True;
        InputOK;
      end;
    ROULEAU_BIS_ZONE_ROUGE :
      begin
        InputOK;
      end;
  end;

end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.ExecuteC;
begin
  if not ToucheUser then // si l'utilisateur presse touche pendant traitement...
    exit;
  Case FTag of
    INIT : begin
          if input.Visible then
            Initialisation
          else
            Close;
        end;
    STATUT :
      begin
        FTag:=PHASE_OK;
        InputOK;
      end;
    QTE :
      begin
        FTag:=PHASE_OK;
        InputOK;
      end;
    STATUT_QTE : begin // 03/03/11 insertion!!!
        //Initialisation;
        FTag:=QTE_OK;
        InputOK;
      end;
    //QST_STATUT, STATUT_QTE, FIN_SAISIE_OK: //BALISAGE : //4, 7 ,9, 10 NON_CONFORME,
    FIN_SAISIE_OK :
      begin
        FTag:=PHASE_OK;
        InputOK;
      end;
    QST_STATUT ://, FIN_SAISIE_OK: //BALISAGE : //4, 7 ,9, 10 NON_CONFORME,
      begin
        // on ne fait rien... pour éviter l'initialisation!
      end;
    SAISIE_OK:
      begin   // on ne fait dorénavant rien du tout : l'annulation se fait comme pour la fin de fab sur le <A>
        //FTag:=FIN_SAISIE_ANNULEE;
        InputOK;
      end;
    SAISIE_BALISAGES, CONFIRMATION_SAISIE_NC:
      begin
      end;
    else
    begin
      Initialisation;
    end;
  end;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.ExecuteV;
begin
  if not ToucheUser then // si l'utilisateur presse touche pendant traitement...
    exit;
  Case FTag of
    INIT : begin
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('Lecture du Rouleau');
          EcritMemo(Flignes);
          AfficheInput;
        end;
    ROULEAU_SAISI : InputOK; //Rouleau_Saisi
    STATUT : InputOK;
    STATUT_QTE : InputOK; // 03/03/11 pp
    ROULEAU_CREE : begin
        //InputOK;
        Close;
      end;
    ATTENTE_NUM_EXTE_BIS : begin
        //demande rouleau bis???
        FTag:=NUM_EXTE_BIS_SAISI;
        Flignes.Clear;
        Flignes.Add('');
        Flignes.Add('Numéro du rouleau client BIS?');
        Flignes.Add('');
        Flignes.Add('');
        EcritMemo(Flignes);
        setdonnees(ROULEAUX_Nume_Exte);
        AfficheInput;
      end;

    // 03/03/11 FIN_SAISIE_OK : InputOK; // , SAISIE_RACC_RI
    CREATION_ROULEAU : InputOK;
    NUM_EXTE_BIS_SAISI : InputOK;
    SAISIE_OK : InputOK;
    CONFIRMATION_SAISIE_NC : begin
        FTag:=STATUT_QTE;
        Flignes.Clear;
        Flignes.Add('Statut par Quantité');
        Flignes.Add('');
        Flignes.Add('FIN STATUT <ECHAP>');
        EcritMemo(Flignes);
        AfficheInput;
        Screen.Cursor:=CrDefault;
      end;
  end;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.ExecuteA;
begin
  if not ToucheUser then // si l'utilisateur presse touche pendant traitement...
    exit;
  Case FTag of
    SAISIE_OK :
        begin
          FTag:=FIN_SAISIE_ANNULEE;
          InputOK;
        end;
  end;
end;

(*----------------------------------------------------------------------------*)
procedure TFCoupure_Rlx.InputOK;
var
  ret : TStringList;
  SQL : String;
  RecordCount : integer;
  Err : Boolean;
  Qte_Float : real;
  PosPoint : integer;

  function  Nombre_Raccords_Restant(Rlx : string) : string;
  var
    nb : integer;
    roul_orig, roul : string;
  begin
    {result:='00000';
    exit;
    }

    nb:=0;
    roul_orig:='xx';
    roul:=Rlx;

    // nbre de raccords sur le rouleau actuel!
    SQL:='SELECT MOUV_ROUL.Nume_Roul, Sum(RACCORD.Nb_Racc) AS SommeDeNb_Racc '+
      'FROM RACCORD INNER JOIN MOUV_ROUL ON RACCORD.Num_Mouv_Roul = MOUV_ROUL.Num '+
      'GROUP BY MOUV_ROUL.Nume_Roul '+
      'HAVING (((MOUV_ROUL.Nume_Roul)='+Rlx+'));';
    ret:=ExecuteSQL(False,SQL,2,RecordCount,Err);
    if Err then
    begin
      Screen.Cursor:=CrDefault;
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
    if trim(ret.Strings[1])<>'' then
      nb:=nb+strtoint(ret.Strings[1]);

    //TraceDebug('roul_orig 1 = '+roul_orig);
    // Recherche des raccords sur les rouleaux d'origine!
    while roul_orig<>'' do
    begin
      //TraceDebug('roul_orig 2 = '+roul_orig);
      SQL:='SELECT ROULEAUX.Nume_Roul_Orig FROM ROULEAUX WHERE (((ROULEAUX.Num)='+roul+'));';
      ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
      roul_orig:=ret.Strings[0];
      roul:=roul_orig;
      //TraceDebug('roul_orig 3 = '+roul_orig);
      if trim(roul_orig)<>'' then // recherche du nbre de raccords effectués!
      begin
        SQL:='SELECT MOUV_ROUL.Nume_Roul, Sum(RACCORD.Nb_Racc) AS SommeDeNb_Racc '+
          'FROM RACCORD INNER JOIN MOUV_ROUL ON RACCORD.Num_Mouv_Roul = MOUV_ROUL.Num '+
          'GROUP BY MOUV_ROUL.Nume_Roul '+
          'HAVING (((MOUV_ROUL.Nume_Roul)='+roul_orig+'));';
        ret:=ExecuteSQL(False,SQL,2,RecordCount,Err);
        if Err then
        begin
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        if trim(ret.Strings[1])<>'' then
          nb:=nb+strtoint(ret.Strings[1]);
      end;
      //TraceDebug('roul_orig 4 = '+roul_orig);
    end;
    result:=inttostr(nb);
  end;


  procedure Recup_Infos_Spec;
  begin
    SQL:='SELECT SPEC_EDIT_INTE.Poids, PALETTE.Num, SPEC_EDIT_INTE.[Pas], '+
          'SPEC_EDIT_INTE.Nomb_Piec_Pas FROM SPEC_EDIT_INTE INNER JOIN '+
          '(DETA_RECE INNER JOIN PALETTE ON DETA_RECE.Num = PALETTE.Nume_Deta_Rece) '+
          'ON SPEC_EDIT_INTE.Num = DETA_RECE.Nume_Spec_Edit_Inte '+
          'WHERE (((PALETTE.Num)='+ROULEAUX_Nume_Pale+'));';

    SQL:='SELECT SPEC_EDIT_INTE.Poids, PALETTE.Num, SPEC_EDIT_INTE.[Pas], '+
          'SPEC_EDIT_INTE.Nomb_Piec_Pas, SPEC_EDIT_INTE.Arro_Qte, '+
          'SPEC_EDIT_INTE.Arrondi FROM SPEC_EDIT_INTE INNER JOIN '+
          '(DETA_RECE INNER JOIN PALETTE ON DETA_RECE.Num = PALETTE.Nume_Deta_Rece) '+
          'ON SPEC_EDIT_INTE.Num = DETA_RECE.Nume_Spec_Edit_Inte '+
          'WHERE (((PALETTE.Num)='+ROULEAUX_Nume_Pale+'));';

    ret:=ExecuteSQL(False,SQL,6, recordCount,Err);
    if Err then
    begin
      Screen.Cursor:=CrDefault;
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
    Poids_Au_Metre:=TransformeEnFloat(ret.strings[0]); // en grammes
    Nb_Pas:=TransformeEnFloat(ret.strings[2]);
    Nomb_Piec_Pas:=TransformeEnFloat(ret.strings[3]);
    Arrondir:=UPPERCASE(ret.Strings[4])='VRAI';
    if trim(ret.strings[5])<>'' then
      Arrondi:=StrToInt(ret.strings[5])
    else
      Arrondi:=0;
  end;

  function Arrondi_Qte(val:string) : string;
  var
    r: integer;
    i : integer;
    s : string;
  begin
    if Arrondi=0 then
      result:=val
    else
    begin
      r:=StrToInt(FloatToStr(Int(StrToFloat(val))));
      i:=r mod Arrondi;
      if i >0 then
      begin
        s:=formatFloat('########',(r/Arrondi));
        if trim(s)='' then s:='1';
        s:=formatFloat('########',(Arrondi*StrToFloat(s)));
        //r:=r+1000-i;
        result:=s;
      end
      else
        result:=val;
      end;
  end;

  procedure Insert;
  begin
    SQL:='SELECT MOUV_ROUL.Num '+
        'FROM MOUV_ROUL WHERE '+
        '(((MOUV_ROUL.Nume_Roul)='+inttostr(Rouleau)+') AND '+
        '((MOUV_ROUL.Nume_Phas_Prod)='+PHAS_PROD_Num+') AND '+
        '((MOUV_ROUL.Usupp) Is Null) AND ((MOUV_ROUL.Dsupp) Is Null)) '+
        'ORDER BY MOUV_ROUL.Num DESC';
    ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
    if Err then
    begin
      Screen.Cursor:=CrDefault;
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
    MOUV_ROUL_Num_PREMIER:=ret.Strings[0];    //A4
    // insert mouv_roul_stat du roul traité

    // Avant l'insertion calcul des quantités avec la bonne unité
    //(l'operateur saisit toujours des poids!
    // l'operateur saisit le poids (qte)
    // calcul de la quantité correspondant
    SQL:='SELECT UNITE.Code, UNITE.Conv_Unit_Réfé FROM UNITE '+
        'WHERE (((UNITE.Num)='+PALETTE_Unite+'));';
    ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
    if Err then
    begin
      Screen.Cursor:=CrDefault;
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
    Code_Unite:=ret.strings[0];
    Conv_Unit_Refe:=TransformeEnFloat(ret.strings[1]);

    if (UPPERCASE(Code_Unite)='KG') or (UPPERCASE(Code_Unite)='CK') then
    begin
      if Unite_saisie='KG' then
      begin
        Qte_Calculee:=TransformeEnFloat(Qte_Roul)/Conv_Unit_Refe;
        Qte_Calculee_Str:=FormatFloat('########.###',Qte_calculee);
        Recup_Infos_Spec;
        Qte_Mesuree_Affichage:=FormatFloat('########.###',TransformeEnFloat(Qte_Roul)/(Poids_Au_Metre*0.001)*Conv_Unit_Refe);
        if GetSite='2' then
        begin
          Qte_Mesuree:=TransformeEnFloat(Qte_Roul)/(Poids_Au_Metre*0.001)*Conv_Unit_Refe;
          Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);
        end
        else
          Qte_Mesuree_Str:='';
      end
      else
      begin
        Recup_Infos_Spec;
        if Poids_Au_Metre=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le poids au metre n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;

        Qte_Calculee:=TransformeEnFloat(Qte_Roul)*Poids_Au_Metre*0.001/Conv_Unit_Refe;
        Qte_Calculee_Str:=FormatFloat('########.###',Qte_Calculee);

        Qte_Mesuree:=TransformeEnFloat(Qte_Roul);
        Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);

        Qte_Roul:=FormatFloat('########.###',TransformeEnFloat(Qte_Roul)*Poids_Au_Metre*0.001);

        Qte_Mesuree_Affichage:=Qte_Mesuree_Str;

      end;

    end
    else if (LOWERCASE(Code_Unite)='m') or (LOWERCASE(Code_Unite)='mm') or (LOWERCASE(Code_Unite)='µm') then
    begin
      Recup_Infos_Spec;
      if Unite_saisie='KG' then
      begin
        if Poids_Au_Metre=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le poids au metre n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        Qte_Calculee:=TransformeEnFloat(Qte_Roul)/Poids_Au_Metre/0.001/Conv_Unit_Refe; //à voir !!!
        Qte_Calculee_Str:=FormatFloat('########.###',Qte_calculee);
        Qte_Mesuree_Affichage:=Qte_Calculee_Str;
        if GetSite='2' then
        begin
          Qte_Mesuree:=TransformeEnFloat(Qte_Roul)/(Poids_Au_Metre*0.001)*Conv_Unit_Refe;
          Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);
        end
        else
          Qte_Mesuree_Str:='';
      end
      else if Unite_saisie='M' then
      begin  // on a saisi la quantité en m
        Qte_Mesuree:=TransformeEnFloat(Qte_Roul);
        Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);

        if Poids_Au_Metre=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le poids au metre n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;

        Qte_Calculee:=TransformeEnFloat(Qte_Roul )/Conv_Unit_Refe; // m/0.001
        Qte_Calculee_Str:=FormatFloat('########.###',Qte_calculee);

        Qte_Roul:=FormatFloat('########.###',TransformeEnFloat(Qte_Roul)*Poids_Au_Metre*0.001);
      end;
    end
    else if (UPPERCASE(Code_Unite)='U') or (UPPERCASE(Code_Unite)='MN') or (UPPERCASE(Code_Unite)='MI') then
    begin
      Recup_Infos_Spec;
      if Unite_saisie='KG' then
      begin
        if Nomb_Piec_Pas=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le Nombre de pièces au pas n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        if Nb_Pas=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le Nombre de pas n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        if Poids_Au_Metre=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le poids au metre n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        //Qte_Calculee:=(TransformeEnFloat(Qte_Roul)/Poids_Au_Metre/0.001/Conv_Unit_Refe)/(Nb_Pas*0.001)*Nomb_Piec_Pas;
        Qte_Calculee:=Int((TransformeEnFloat(Qte_Roul)/Poids_Au_Metre/0.001/Conv_Unit_Refe)/(Nb_Pas*0.001)*Nomb_Piec_Pas);
        //Qte_Calculee_Str:=FormatFloat('########.###',Qte_calculee);
        Qte_Calculee_Str:=FormatFloat('########',Qte_calculee);
        Qte_Mesuree_Affichage:=FormatFloat('########.###',TransformeEnFloat(Qte_Roul)/Poids_Au_Metre/0.001/Conv_Unit_Refe);
        if GetSite='2' then
        begin
          Qte_Mesuree:=TransformeEnFloat(Qte_Roul)/(Poids_Au_Metre*0.001)*Conv_Unit_Refe;
          Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);
        end
        else
          Qte_Mesuree_Str:='';
      end
      else if Unite_saisie='M' then
      begin
        Qte_Mesuree:=TransformeEnFloat(Qte_Roul);
        Qte_Mesuree_Str:=FormatFloat('########.###',Qte_Mesuree);

        if Poids_Au_Metre=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le poids au metre n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;

        if Nomb_Piec_Pas=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le Nombre de pièces au pas n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        if Nb_Pas=0 then
        begin
          Screen.Cursor:=CrDefault;
          GestionErreur('Le Nombre de pas n''est pas défini dans la spec interne'+#13+'Abandon');
          ToucheUser:=True;
          Initialisation;
          Exit;
        end;
        //Qte_Calculee:=(TransformeEnFloat(Qte_Roul)/Conv_Unit_Refe)/(Nb_Pas*0.001)*Nomb_Piec_Pas;
        Qte_Calculee:=Int((TransformeEnFloat(Qte_Roul)/Conv_Unit_Refe)/(Nb_Pas*0.001)*Nomb_Piec_Pas);
        //Qte_Calculee_Str:=FormatFloat('########.###',Qte_calculee);
        Qte_Calculee_Str:=FormatFloat('########',Qte_calculee);
        Qte_Roul:=FormatFloat('########.###',TransformeEnFloat(Qte_Roul)*Poids_Au_Metre*0.001);
      end;
    end; // U, MN ou Mi

    if Pos(',',Qte_Roul)>0 then // Transformer la ',' en '.' sinon erreur SQL!
    begin
      Qte_Roul:=Copy(Qte_Roul,0,Pos(',',Qte_Roul)-1)+'.'+
                 Copy(Qte_Roul,Pos(',',Qte_Roul)+1,Length(Qte_Roul));
    end;

    Qte_Reelle:='0';
    if Arrondir then // il faut arrrondir à Arrondi prés
    begin
      if (PALETTE_Unite='1') or (GetSite='1') then
      // on est dans le cas ou on ne déduit pas les qtés de raboutage à la qté compteur
      // on fait donc l'arrondi ici
      // pour le cas des pièces à Saugues, on fait l'arrondi APRES avoir déduit
      // les qtes non conformes, raboutage etc. dans la partie VERIF_STATUT
      // on ne devrait jamais arrondir les kilos, ou à Siaugues, mais on ne sait jamais!
      // je le laisse quand mm ici!
      begin
        if Statut_Qte_Roul=Statut_Roul then
        begin
          // tester si derniere phase de l'OF et si qte conforme!
          //recuperation du dernier num de phase prod (L0)
          //SQL_0013
          SQL:='SELECT PHAS_PROD.Num FROM PHAS_PROD WHERE '+
               '(((PHAS_PROD.Num_OF)='+PHAS_PROD_Num_OF+') AND '+
               '((PHAS_PROD.Usupp) Is Null) AND ((PHAS_PROD.Dsupp) Is Null)) '+
               'ORDER BY PHAS_PROD.Nume_Ordr DESC';
          ret:=ExecuteSQL(False,SQL,1,RecordCount,Err);
          PHAS_PROD_Num_L0 :=ret.Strings[0]; //L0
          if PHAS_PROD_Num_L0=PHAS_PROD_Num then
          begin
            Qte_Reelle:=Qte_Calculee_Str;
            Qte_Calculee_Str:=Arrondi_Qte(Qte_Calculee_Str);
          end;
        end;
      end;
    end;

    if Pos(',',Qte_Calculee_Str)>0 then // Transformer la ',' en '.' sinon erreur SQL!
    begin
      Qte_Calculee_Str:=Copy(Qte_Calculee_Str,0,Pos(',',Qte_Calculee_Str)-1)+'.'+
                 Copy(Qte_Calculee_Str,Pos(',',Qte_Calculee_Str)+1,Length(Qte_Calculee_Str));
    end;

    if Pos(',',Qte_Mesuree_Str)>0 then // Transformer la ',' en '.' sinon erreur SQL!
    begin
      Qte_Mesuree_Str:=Copy(Qte_Mesuree_Str,0,Pos(',',Qte_Mesuree_Str)-1)+'.'+
                 Copy(Qte_Mesuree_Str,Pos(',',Qte_Mesuree_Str)+1,Length(Qte_Mesuree_Str));
    end;
    if Pos(',',Qte_Reelle)>0 then // Transformer la ',' en '.' sinon erreur SQL!
    begin
      Qte_Reelle:=Copy(Qte_Reelle,0,Pos(',',Qte_Reelle)-1)+'.'+
                 Copy(Qte_Reelle,Pos(',',Qte_Reelle)+1,Length(Qte_Reelle));
    end;

    // fin du calcul de la quantité correspondant au poids de la palette

    // SQL_0013
    if (Qte_Mesuree_Str='0') or (Qte_Mesuree_Str='') then   // pour pas afficher de 0!!!
      SQL:='INSERT INTO MOUV_ROUL_STAT (Nume_Mouv_Roul,Nume_Sous_Type_Stat,'+
        'Poids_Net,Quantité,Qte_reelle,Ucréa,Dcréa,Unite)  '+
        'VALUES('+MOUV_ROUL_Num_PREMIER+','+IntToStr(Statut_Qte_Roul)+
        ','+Qte_Roul+','''+Qte_Calculee_Str+''','''+ Qte_reelle+''','''+GetNomMachine+''','''+DateToStr(now)+
        ''','+PALETTE_Unite+')'
    else
      SQL:='INSERT INTO MOUV_ROUL_STAT (Nume_Mouv_Roul,Nume_Sous_Type_Stat,'+
        'Poids_Net,Qte_mesu,Quantité,Qte_reelle,Ucréa,Dcréa,Unite)  '+
        'VALUES('+MOUV_ROUL_Num_PREMIER+','+IntToStr(Statut_Qte_Roul)+
        ','+Qte_Roul+','''+Qte_Mesuree_Str+''','''+Qte_Calculee_Str+''','''+ Qte_reelle+''','''+GetNomMachine+''','''+DateToStr(now)+
        ''','+PALETTE_Unite+')';
    ExecuteSQL(True,SQL,0, recordCount,Err);
    if Err then
    begin
      Screen.Cursor:=CrDefault;
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
  end;

  (*
  procedure Suppr_Roul_Superviseur;
  var
    Fichier : string;
    Nb_Brins, i: integer;
    Num_Brin : integer;
    l : TStringList;
    cmd : string;
    s : string;
  begin
    // Insertion dans un fichier texte le n° du rouleau pour que l'info indus le récupere et le mette dans une variable
    // pour le moment tests. + tard il faut tester si on fait bien la mise en fab sur la bonne machine
    // sinon il faut écrire sur le poste du superviseur en utilisant une table listant les adresses IP de toutes les machines
    // enregistrement dans \\
    SQL:='SELECT MACHINE.Num, MACHINE.Code, MACHINE.IP_Superv, MACHINE.Nb_Brins FROM MACHINE WHERE (((MACHINE.Num)='+MACHINE_Num+'));';
    ret:=ExecuteSQL(False,SQL,4, recordCount,Err);
    if recordCount=0 then
    begin
      Screen.Cursor:=CrDefault;
      GestionErreur('ERREUR dans la selection de la machine Phas_prod! ABANDON...');
      ToucheUser:=True;
      Initialisation;
      Exit;
    end;
    if trim(ret.Strings[2])='' then exit; // pas besoin de sauvegarder le n° de rouleau (ex : BM)

    if trim(ret.Strings[3])='' then Nb_Brins:=1
    else Nb_Brins:=StrToInt(ret.Strings[3]);
    TraceDebug('Copie_Roul_Superviseur '+GetNomMachine+ ' sur '+ret.Strings[2]);
    // Test si on fait la mise en fab sur la mchine de prod
    if UPPERCASE(GetNomMachine)=ret.Strings[2] then // on ecrit directement sur D:\Archive
      Fichier:='D:\Archive\Roul.txt'
    else
    begin
      Fichier:='\\'+ret.Strings[2]+'\Archive\Roul.txt';     // est-ce-qu'il faut gérer la connection avec nom d'utilisateur? PC_B16\admin - 6348

      if not DirectoryExists('\\'+ret.Strings[2]+'\Archive') then
      begin
        cmd:='net use '+'\\'+ret.Strings[2]+'\Archive'+' /user:admin 6348';
        WinExec(PAnsiChar(AnsiString(cmd)),sw_normal); // ne sais pas si ça marche!
        // avant passage XE5 WinExec(PChar(cmd),sw_normal);
        sleep(1000);
        Application.ProcessMessages;
      end;
    end;

    if not FileExists(Fichier) then
    begin
      TraceDebug('Tentative d''ecriture dans '+Fichier);
      TraceDebug('Depuis la machine '+GetNomMachine);
      TraceDebug('Erreur dans le saveToFile');
      GestionErreur('Erreur dans le partage du rouleau avec la supervision! Contacter le service Informatique!');
      exit;
    end;

    l:=TStringList.Create;
    l.LoadFromFile(Fichier);
    if l.Count=0 then // le fichier n'existe pas? on ne fait rien!
    begin
    end
    else
    begin
      // Chercher sur quel brin le rouleau a été mis en fab
      {
      for i:=0 to l.Count-1 do
        if StrToInt(Copy(l.Strings[i],pos(';',l.strings[i])+1,length(l.strings[i])))=Rouleau then
          l.Strings[i]:=Copy(l.Strings[i],0,pos(';',l.strings[i]))+'0';
          }
      for i:=0 to l.Count-1 do
      begin
        if trim(l.Strings[i])<>'' then
        begin
          //showmessage(l.Strings[i]);
          s:=Copy(l.Strings[i],pos(';',l.strings[i])+1,length(l.strings[i])); // OF;roul
          //showmessage(s);
          //showmessage(Copy(s,pos(';',s)+1,length(s)));

          if StrToInt(Copy(s,pos(';',s)+1,length(s)))=Rouleau then
            l.Strings[i]:=Copy(l.Strings[i],0,pos(';',l.strings[i]))+'0';
        end;
      end;
    end;
    try
      l.SaveToFile(Fichier);
    except
      TraceDebug('Tentative d''ecriture dans '+Fichier);
      TraceDebug('Depuis la machine '+GetNomMachine);
      TraceDebug('Erreur dans le saveToFile');
      GestionErreur('Erreur dans le partage du rouleau avec la supervision! Contacter le service Informatique!');
    end;
    l.Free;
  end;
  *)

begin
  Case FTag of
    INIT : begin
          try
            if trim(GetDonnees)='' then
              exit;
            Rouleau:=StrToInt(GetDonnees); //A0
          except
            Screen.Cursor:=CrDefault;
            GestionErreur('ERREUR SAISIE!');
            SetDonnees('');
            ExecuteV;
            exit;
          end;
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;

          //S_03
          //date A7 heur A8 debu,PHAS_PROD.Nume_Ordr F0, PHAS_PROD.Num E9
          //Mouv_roul.num G9 et pr verif roul mis en fab
          //SQL_0008
          SQL:='SELECT MOUV_ROUL.Date_Debu, MOUV_ROUL.Heur_Debu, '+
              'PHAS_PROD.Nume_Ordr, PHAS_PROD.Num, MOUV_ROUL.Num, MOUV_ROUL.Cote_Mach, PHAS_PROD.Num_OF FROM '+
              'MOUV_ROUL INNER JOIN PHAS_PROD ON '+
              'MOUV_ROUL.Nume_Phas_Prod = PHAS_PROD.Num WHERE '+
              '(((MOUV_ROUL.Date_Debu) Is Not Null) AND '+
              '((MOUV_ROUL.Heur_Debu) Is Not Null) AND '+
              '((MOUV_ROUL.Date_Fin) Is Null) AND '+
              '((MOUV_ROUL.Heur_Fin) Is Null) AND '+
              '((MOUV_ROUL.Nume_Roul)='+inttostr(Rouleau)+') AND '+
              '((MOUV_ROUL.Usupp) Is Null) AND ((MOUV_ROUL.Dsupp) Is Null)) '+
              'ORDER BY MOUV_ROUL.Date_Fin DESC , MOUV_ROUL.Heur_Fin DESC';
          ret:=ExecuteSQL(False,SQL,7, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('Coupure Rouleau impossible'+#13+'Le rouleau n''est pas en fab');
            ExecuteV;
            exit;
          end;
          //date A7 heur A8 debu,PHAS_PROD.Nume_Ordr F0, PHAS_PROD.Num E9
          //Mouv_roul.num G9 et pr verif roul mis en fab
          MOUV_ROUL_Date_Debu:=ret.Strings[0];   //A7
          MOUV_ROUL_Heur_Debu:=ret.Strings[1];   //A8
          PHAS_PROD_Nume_Ordr:=ret.Strings[2];   //F0
          PHAS_PROD_Num:=ret.Strings[3];         //E9
          MOUV_ROUL_Num:=ret.Strings[4];         //G9
          MOUV_ROUL_COTE:=ret.Strings[5];
          PHAS_PROD_Num_OF:=ret.Strings[6];

          //req infos roul
          //A1,Num ext A2,Num pal, I0 Unite pal
          //SQL_0001
          SQL:='SELECT ROULEAUX.Nume_Exte, ROULEAUX.Nume_Pale, PALETTE.Unite FROM '+
              'ROULEAUX INNER JOIN PALETTE ON ROULEAUX.Nume_Pale = PALETTE.Num WHERE '+
              '(((ROULEAUX.Num)='+Inttostr(Rouleau)+') AND '+
              '((ROULEAUX.Usupp) Is Null) AND ((ROULEAUX.Dsupp) Is Null))';
          ret:=ExecuteSQL(False,SQL,3, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('Rouleau Introuvable');
            ExecuteV;
            exit;
          end;

          //*********************************************************
          // tester ici si la palette du rouleau a été validée FS!!
          //*********************************************************
          SQL:='SELECT ROULEAUX.Num, PALETTE.Valide FROM ROULEAUX LEFT JOIN PALETTE '+
              'ON ROULEAUX.Nume_Pale = PALETTE.Num '+
              'WHERE (((ROULEAUX.Num)='+Inttostr(Rouleau)+') AND ((PALETTE.Valide)=1));';
          ExecuteSQL(False,SQL,1,recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            ExecuteV;
            Exit;
          end;
          if (recordcount>0)then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('Coupure du rouleau impossible'+#13+
                          'La palette a été validée Fiche Suiveuse!');
            ExecuteV;
            exit;
          end;

          ROULEAUX_Nume_Exte:=ret.Strings[0];  //A1
          ROULEAUX_Nume_Pale:=ret.Strings[1];  //A2
          PALETTE_Unite:=ret.Strings[2];       //I0
          Screen.Cursor:=CrDefault;

          // test si l'unité de la palette est bien renseignée!
          if trim(PALETTE_Unite)='' then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('L''unité de la palette n''est pas renseignée!'+#13+'Vérifier puis refaire la coupure');
            ExecuteV;
            Exit;
          end;


          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('Rouleau '+GetSociete);
          Flignes.Add('   '+GetDonnees);
          Flignes.Add('Rouleau Client');
          Flignes.Add('   '+ROULEAUX_Nume_Exte);
          Flignes.Add('Palette');
          Flignes.Add('   '+ROULEAUX_Nume_Pale);
          Flignes.Add('');
          Flignes.Add('ANNULER <ECHAP>   SUITE <ENTREE>');
          EcritMemo(Flignes);
          //FTag:=ROULEAU_SAISI;
          FTag:=ATTENTE_NUM_EXTE_BIS;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
        end;  // Case 0
    NUM_EXTE_BIS_SAISI : begin
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          ROULEAUX_Nume_Exte_BIS:=GetDonnees;
          FTag:=ROULEAU_SAISI;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
          InputOK;
        end;
    ROULEAU_SAISI : begin // ROULEAU_SAISI
          ToucheUser:=False;
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('      Le rouleau BIS est-il      ');
          Flignes.Add('dans la même phase de production?');
          Flignes.Add('');
          Flignes.Add('NON <0>                   OUI <1>');
          EcritMemo(Flignes);
          FTag:=QST_PHASE;
          ToucheUser:=True;
          Screen.Cursor:=CrDefault;
        end; // case 1
    PHASE_OK : begin //PHASE_OK
          //SK_VERIF
          ToucheUser:=False;
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('Vérification...');
          EcritMemo(Flignes);
          Application.ProcessMessages;
          // y a t il 1 phase de prod A3
          //SQL_0002
          SQL:='SELECT MOUV_ROUL.Nume_Phas_Prod FROM MOUV_ROUL WHERE '+
              '(((MOUV_ROUL.Date_Fin) Is Not Null) AND '+
              '((MOUV_ROUL.Heur_Fin) Is Not Null) AND '+
              '((MOUV_ROUL.Nume_Roul)='+inttostr(Rouleau)+') AND '+
              '((MOUV_ROUL.Usupp) Is Null) AND '+
              '((MOUV_ROUL.Dsupp) Is Null)) '+
              'ORDER BY MOUV_ROUL.Date_Fin DESC , MOUV_ROUL.Heur_Fin DESC';
          ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            A5:='0PHASE';
          end
          else
          begin
            MOUV_ROUL_Nume_Phas_Prod:=ret.Strings[0];
            A5:='PHASE';
          end;
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('Statut Rouleau traité ?');
          Flignes.Add('');
          Flignes.Add('');
          EcritMemo(Flignes);
          AfficheInput;
          FTag:=QST_STATUT;
          ToucheUser:=True;
          Screen.Cursor:=CrDefault;
        end; //case 3
    QST_STATUT : begin  //QST_STATUT
          try
            if trim(GetDonnees)='' then
              exit;
            Statut_Roul:=StrToInt(GetDonnees); //B0
          except
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('Statut Rouleau traité ?');
            Flignes.Add('');
            Flignes.Add('');
            EcritMemo(Flignes);
            AfficheInput;
            FTag:=QST_STATUT;
            ToucheUser:=True;
            Screen.Cursor:=CrDefault;
          end;
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          // Libellé Statut...
          //SQL_0003
          SQL:='SELECT TYPE_STAT.Libellé, TYPE_STAT.Code FROM TYPE_STAT WHERE '+
              '(((TYPE_STAT.Num)='+GetDonnees+') AND '+
              '((TYPE_STAT.Usupp) Is Null) AND ((TYPE_STAT.Dsupp) Is Null))';
          ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            GestionErreur('Erreur Statut');
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('Statut Rouleau traité ?');
            Flignes.Add('');
            Flignes.Add('');
            EcritMemo(Flignes);
            AfficheInput;
            FTag:=QST_STATUT;
            ToucheUser:=True;
            Screen.Cursor:=CrDefault;
            exit;
          end;
          TYPE_STAT_Libelle:=ret.Strings[0];  //B1
          TYPE_STAT_Code:=ret.Strings[1];     // D5
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('Statut : ');
          Flignes.Add('   '+TYPE_STAT_Libelle);
          Flignes.Add('');
          Flignes.Add('ANNULER <ECHAP>     OK <ENTREE>');
          EcritMemo(Flignes);
          FTag:=STATUT;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
        end; //case 4
    STATUT : begin // STATUT
          ToucheUser:=False;
          //SUIT
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('STATUT PAR QUANTITE (rouleau traité)');
          Flignes.Add('');
          Flignes.Add('FIN STATUT <ECHAP>');
          EcritMemo(Flignes);
          AfficheInput;
          FTag:=STATUT_QTE;
          ToucheUser:=True;
        end;
    STATUT_QTE : begin // STATUT_QTE
          try
            if trim(GetDonnees)='' then
              exit;
            Statut_Qte_Roul:=StrToInt(GetDonnees); //C0
          except
            GestionErreur('ERREUR SAISIE!');
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('STATUT PAR QUANTITE (rouleau traité)');
            Flignes.Add('');
            Flignes.Add('FIN STATUT <ECHAP>');
            EcritMemo(Flignes);
            AfficheInput;
            FTag:=STATUT_QTE;
            ToucheUser:=True;
            exit;
          end;
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          // Libellé Statut
          //SQL_0012
          SQL:='SELECT SOUS_TYPE_STAT.Libellé, SOUS_TYPE_STAT.Code FROM '+
              'SOUS_TYPE_STAT WHERE '+
              '(((SOUS_TYPE_STAT.Num)='+GetDonnees+') AND '+
              '((SOUS_TYPE_STAT.Usupp) Is Null) AND '+
              '((SOUS_TYPE_STAT.Dsupp) Is Null))';
          ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            GestionErreur('Erreur Statut');
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('STATUT PAR QUANTITE (rouleau traité)');
            Flignes.Add('');
            Flignes.Add('FIN STATUT <ECHAP>');
            EcritMemo(Flignes);
            AfficheInput;
            FTag:=STATUT_QTE;
            ToucheUser:=True;
            exit;
          end;
          SOUS_TYPE_STAT_Libelle:=ret.Strings[0]; //C1
          SOUS_TYPE_STAT_Code:=ret.Strings[1];    //H2

          if GetSite='1' then // Site de Siaugues : on indique tout en kg!
            Unite_saisie:='KG'
          else if GetSite='2' then// Site de Saugues : on a ds compteurs métriques, sauf pour les
          // valeurs non conformes que l'on pese!
          begin
            //Unite_saisie:='M';
            if Statut_Roul=1 then //ERO 24/02/11 pour gérer les statuts qtés multiples
            begin
              if PALETTE_Unite='1' then
              begin
                Unite_saisie:='KG';
              end
              else
              begin
                if GetDonnees ='1' then   // Les valeurs conformes sont exprimées en m
                  Unite_saisie:='M'
                else // les valeurs non conformes sont exprimées en kg
                  Unite_saisie:='KG';
              end;
            end
            else// if Statut_Rouleau=2 then
            begin
              if PALETTE_Unite='1' then
                Unite_saisie:='KG'
              else
              begin
                //Unite_saisie:='M';
                if GetDonnees ='2' then   // Les valeurs conformes sont exprimées en m
                  Unite_saisie:='M'
                else // les valeurs non conformes sont exprimées en kg
                  Unite_saisie:='KG';
              end;
            end;
          end
          else
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('Erreur dans la définition du site de la machine!');
            SetDonnees('');
            Initialisation;
            Exit;
          end;
          Flignes.Clear;
          Flignes.Add('');
          if Unite_saisie='KG' then
            Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle)
          else
            if Statut_Qte_Roul= Statut_Roul then
              Flignes.Add('QUANTITE COMPTEUR ?')
            else
              Flignes.Add('LONGUEUR EN METRES '+SOUS_TYPE_STAT_Libelle);
          {Flignes.Add('');
          Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle);
          Flignes.Add('');
          }
          Flignes.Add('ANNULER <ECHAP>    OK <ENTREE>');
          EcritMemo(Flignes);
          AfficheInput;
          FTag:=QTE;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
        end; //case 7
    QTE : begin // QTE
          try
            if trim(GetDonnees)='' then
              exit;
            try
              // Ici beaucoup de blabla pour savoir si l'utilisateur a typé une
              // une bonne quantité. Attention, le float support uniquement
              // la virgule, alors que le SQL uniquement le point!
              PosPoint:=pos('.',GetDonnees);
              if PosPoint>0 then
              begin
                try
                  Qte_Float:=StrToFloat(GetDonnees);
                except
                  try
                    Qte_Float:=StrToFloat(Copy(GetDonnees,0,PosPoint-1)+','+
                                          Copy(GetDonnees,PosPoint+1,Length(GetDonnees)));
                  except
                    Flignes.Clear;
                    Flignes.Add('');
                    if Unite_saisie='KG' then
                      Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle)
                    else
                      Flignes.Add('LONGUEUR EN METRES '+SOUS_TYPE_STAT_Libelle);
                    //Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle);
                    Flignes.Add('');
                    Flignes.Add('ANNULER <ECHAP>    OK <V>');
                    EcritMemo(Flignes);
                    AfficheInput;
                    FTag:=QTE;
                    Screen.Cursor:=CrDefault;
                    ToucheUser:=True;
                    exit;
                  end;
                end;
              end
              else
              begin
                //StrToFloat(GetDonnees); //E0
              end;
              if Pos(',',GetDonnees)>0 then // Transformer la ',' en '.' sinon erreur SQL!
              begin
                SetDonnees(Copy(GetDonnees,0,Pos(',',GetDonnees)-1)+'.'+
                           Copy(GetDonnees,Pos(',',GetDonnees)+1,Length(GetDonnees)));
              end;
            except
              if pos('.',GetDonnees)=0 then
              begin
                Flignes.Clear;
                Flignes.Add('');
                if Unite_saisie='KG' then
                  Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle)
                else
                  Flignes.Add('LONGUEUR EN METRES '+SOUS_TYPE_STAT_Libelle);
                //Flignes.Add('POIDS EN KG '+SOUS_TYPE_STAT_Libelle);
                Flignes.Add('');
                Flignes.Add('ANNULER <ECHAP>    OK <V>');
                EcritMemo(Flignes);
                AfficheInput;
                FTag:=QTE;
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                exit;
              end;
            end;
            Qte_Roul:=GetDonnees; //E0
          except
            Screen.Cursor:=CrDefault;
            GestionErreur('ERREUR SAISIE!');
            SetDonnees('');
            ExecuteV;
            exit;
          end;

          Insert; // insertion des qtes au fur et à mesure

          {// supprimé juin 2011 suite à la mise en place du calcul auto des qtes conf par rapport aux déchets
          if GetSite='2' then
          // Si roul conforme : afficher qté NC juste apres la saisie : kg et m
          // Sinon ne rien faire
          begin
            // si rouleau conforme
            if Statut_Roul=1 then
            begin
              if (Statut_Qte_Roul<>1) and (PALETTE_Unite<>'1') then // si qté saisie non conforme
              begin
                FTag:=CONFIRMATION_SAISIE_NC;
                Flignes.Clear;
                Flignes.Add('Quantité saisie :');
                Flignes.Add(Qte_Roul+' kg - '+Qte_Mesuree_Affichage+' m');
                Flignes.Add('<OK>');
                EcritMemo(Flignes);
                ToucheUser:=True;
                Screen.Cursor:=CrDefault;
              end;
            end;
          end;
          }

          if FTag<>CONFIRMATION_SAISIE_NC then
          begin
            FTag :=STATUT;
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            InputOK;
          end;

          //*****************
          {FTag :=STATUT;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
          InputOK;
          }

          //*****************
          { 03/03/11
          // rajout tag ici!! ppp
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          Insert;

          Screen.Cursor:=CrDefault;
          ToucheUser:=True;

          }

        end; // case 8
    QTE_OK : begin //03/03/11
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          if GetSite='1' then
          begin
            FTag:=SAISIE_BALISAGES;
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('');
            Flignes.Add('Nombre de balisages?');
            Flignes.Add('');
            EcritMemo(Flignes);
            AfficheInput;
          end
          else
          begin
            Nb_Balisages:=0;
            FTag:=FIN_SAISIE_OK;
            InputOK;
          end;

          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
        end;
    SAISIE_BALISAGES : begin
          // nombre de balisages
          try
            if trim(GetDonnees)='' then
              exit;
            Nb_Balisages:=StrToInt(GetDonnees); //Q0
          except
            Screen.Cursor:=CrDefault;
            GestionErreur('ERREUR SAISIE!');
            SetDonnees('');
            ExecuteV;
            exit;
          end;
          FTag:=FIN_SAISIE_OK;
          InputOK;
        end;
    FIN_SAISIE_OK: begin //BALISAGE
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;

          if trim(MOUV_ROUL_Num_PREMIER)='' then // on n'a jamais inséré de qté
          begin
            Screen.Cursor:=CrDefault;
            GestionErreur('Vous devez renseigner au moins une quantité');
            ToucheUser:=True;
            FTag:=STATUT;
            InputOK;
            Exit;
          end;

          // Mise à jour du fichier texte 
          //Suppr_Roul_Superviseur;

          if D3='CONFO' then
          begin
            //SQL_0021
            SQL:='UPDATE MOUV_ROUL SET '+
                'Nume_Type_Stat='+IntToStr(Statut_Roul)+','+
                'Umodif='''+GetNomMachine+''','+
                'Dmodif='''+DateToStr(now)+''','+
                'Date_Fin='''+DateToStr(now)+''','+
                'Heur_Fin='''+TimeToStr(time)+''','+
                'Balisages='+Inttostr(Nb_Balisages)+
                ' WHERE  '+
                '((MOUV_ROUL.Num='+MOUV_ROUL_Num_PREMIER+') AND '+
                '(MOUV_ROUL.Usupp Is Null) AND (MOUV_ROUL.Dsupp Is Null))';
            ExecuteSQL(True,SQL,0, recordCount,Err);
            if Err then
            begin
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              Initialisation;
              Exit;
            end;
          end
          else
          begin
            //SQL_0014
            // MAJ mouv_roul du roul traité PV
            SQL:='UPDATE MOUV_ROUL SET '+
                'Nume_Type_Stat='+inttostr(Statut_Roul)+','+
                'Umodif='''+GetNomMachine+''','+
                'Dmodif='''+DateToStr(now)+''','+
                'Date_Fin='''+DateToStr(now)+''','+
                'Heur_Fin='''+TimeToStr(time)+''','+
                'Balisages='+IntToStr(Nb_Balisages)+
                ' WHERE  '+
                '((MOUV_ROUL.Num='+MOUV_ROUL_Num_PREMIER+') AND '+
                '(MOUV_ROUL.Usupp Is Null) AND (MOUV_ROUL.Dsupp Is Null))';
            ExecuteSQL(True,SQL,0, recordCount,Err);
            if Err then
            begin
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              Initialisation;
              Exit;
            end;
          end;
          //Saugues : Affichage de ce que l'utilisateur a saisi!
          if GetSite='2' then
          begin
            if PALETTE_Unite<>'1' then
            begin
              //////// désormais SI UNITE DE LA PALETTE EN PIECES dans la qté conforme (ou NC si roul NC), on indique la valeur du compteur
              // ici il faut enlever le poids de raboutage, nc, etc à la valeur du compteur
              // Ici qté conforme (ou NC si rouleau NC)
              SQL:='SELECT MOUV_ROUL_STAT.Num, MOUV_ROUL_STAT.Quantité FROM MOUV_ROUL_STAT '+
                'WHERE (((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+') AND '+
                '((MOUV_ROUL_STAT.Nume_Sous_Type_Stat)='+InttoStr(Statut_Roul)+') AND '+
                '((MOUV_ROUL_STAT.Usupp) Is Null) AND ((MOUV_ROUL_STAT.Dsupp) Is Null));';

              ret:=ExecuteSQL(False,SQL,2,RecordCount,Err);
              Qte_Corrigee:=TransformeEnFloat(ret.strings[1]);
              Mouv_Roul_Stat_Num_A_Corriger:=ret.Strings[0];

              // Ici on récupère toutes les qtés <> de Conforme (ou de NC si Roul NC)
              SQL:='SELECT sum(MOUV_ROUL_STAT.Quantité) as somme_qte FROM MOUV_ROUL_STAT '+
                'WHERE (((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+') AND '+
                '((MOUV_ROUL_STAT.Nume_Sous_Type_Stat)<>'+IntToStr(Statut_Roul)+') AND '+
                '((MOUV_ROUL_STAT.Usupp) Is Null) AND ((MOUV_ROUL_STAT.Dsupp) Is Null));';

              SQL:='SELECT Sum(MOUV_ROUL_STAT.Quantité) AS somme_qte FROM MOUV_ROUL_STAT '+
                'LEFT JOIN SOUS_TYPE_STAT ON MOUV_ROUL_STAT.Nume_Sous_Type_Stat = SOUS_TYPE_STAT.Num ' +
                'WHERE (((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+') '+
                'AND ((MOUV_ROUL_STAT.Nume_Sous_Type_Stat)<>'+IntToStr(Statut_Roul)+') AND '+
                '((MOUV_ROUL_STAT.Usupp) Is Null) AND ((MOUV_ROUL_STAT.Dsupp) Is Null) '+
                'AND ((SOUS_TYPE_STAT.Passe_Dans_Compt)=1));';

              ret:=ExecuteSQL(False,SQL,1,RecordCount,Err);

              //if TransformeEnFloat(ret.strings[0])<>0 then // a voir si je le laisse!
              // mis en commentaire pour etre sure que l'arrondi se fait bien dans
              // tous les cas, mm si y'a pas de qté non conforme
              begin
                Qte_Corrigee:=Int(Qte_Corrigee-TransformeEnFloat(ret.strings[0]));    // en pièces!!

                Qte_Reelle:='0';

                // Cas ou il faut arrondir pour le client
                if Arrondir then // il faut arrrondir à Arrondi prés
                begin
                  // pour le cas des pièces à Saugues, on fait l'arrondi APRES avoir déduit
                  // les qtes non conformes, raboutage etc., c'est-à-dire ICI
                  // on ne devrait jamais arrondir les kilos, ou à Siaugues, mais
                  // la fonction d'arrondi est quand mm dans la procedure Insert;

                  //if Statut_Qte_Roul=Statut_Rouleau then
                  begin
                    // tester si derniere phase de l'OF et si qte conforme!
                    //recuperation du dernier num de phase prod (L0)
                    //SQL_0013
                    SQL:='SELECT PHAS_PROD.Num FROM PHAS_PROD WHERE '+
                         '(((PHAS_PROD.Num_OF)='+PHAS_PROD_Num_OF+') AND '+
                         '((PHAS_PROD.Usupp) Is Null) AND ((PHAS_PROD.Dsupp) Is Null)) '+
                         'ORDER BY PHAS_PROD.Nume_Ordr DESC';
                    ret:=ExecuteSQL(False,SQL,1,RecordCount,Err);
                    PHAS_PROD_Num_L0 :=ret.Strings[0]; //L0
                    if PHAS_PROD_Num_L0=PHAS_PROD_Num then
                    begin
                      Qte_Reelle:=FormatFloat('######.##',Qte_Corrigee);
                      Qte_Corrigee:=StrToFloat(Arrondi_Qte(FormatFloat('######.##',Qte_Corrigee)));
                    end;
                  end;
                end;

                // faire l'update ici!!!!!
                Qte_Calculee:=(Qte_Corrigee*Nb_Pas*0.001)/Nomb_Piec_Pas*Conv_Unit_Refe; // en m !!!

                //updates!!!!!!
                SQL:='UPDATE MOUV_ROUL_STAT SET MOUV_ROUL_STAT.Qte_mesu = '+FormatFloat('########.###',Qte_Calculee)+', '+   // en m
                  'MOUV_ROUL_STAT.Quantité = '+FormatFloat('########',Qte_Corrigee)+', '+                                   // en pieces
                  'MOUV_ROUL_STAT.Qte_reelle = '+Qte_Reelle+', '+                                   // réelle au cas ou on aurait arrondi
                  'MOUV_ROUL_STAT.Poids_Net = '+FormatFloat('########.###',Qte_Calculee*Poids_Au_Metre*0.001)+               // en kg
                  ' WHERE (((MOUV_ROUL_STAT.Num)='+Mouv_Roul_Stat_Num_A_Corriger+'));';

                SQL:='UPDATE MOUV_ROUL_STAT SET MOUV_ROUL_STAT.Qte_mesu = '+RemplaceVirguleParPoint(FormatFloat('########.###',Qte_Calculee))+', '+   // en m
                  'MOUV_ROUL_STAT.Quantité = '+RemplaceVirguleParPoint(FormatFloat('########',Qte_Corrigee))+', '+                                   // en pieces
                  'MOUV_ROUL_STAT.Qte_reelle = '+RemplaceVirguleParPoint(Qte_Reelle)+', '+                                   // réelle au cas ou on aurait arrondi
                  'MOUV_ROUL_STAT.Poids_Net = '+RemplaceVirguleParPoint(FormatFloat('########.###',Qte_Calculee*Poids_Au_Metre*0.001))+               // en kg
                  ' WHERE (((MOUV_ROUL_STAT.Num)='+Mouv_Roul_Stat_Num_A_Corriger+'));';

                ret:=ExecuteSQL(True,SQL,1,RecordCount,Err);
              end;

              // Fin de la MAJ!!!
            end;

               {
            if Session_FM.Active then
              Session_FM.Active:=False;
              }
            QuerySQL.Active:=False;
            QuerySQL.SQL.Clear;

            SQL:='SELECT SOUS_TYPE_STAT.Libellé as Statut, MOUV_ROUL_STAT.Qte_mesu, MOUV_ROUL_STAT.Poids_Net, '+
              'MOUV_ROUL_STAT.Quantité, MOUV_ROUL_STAT.Unite, UNITE.Libellé as uni '+
              'FROM (MOUV_ROUL_STAT LEFT JOIN SOUS_TYPE_STAT ON ' +
              'MOUV_ROUL_STAT.Nume_Sous_Type_Stat = SOUS_TYPE_STAT.Num) LEFT JOIN ' +
              'UNITE ON MOUV_ROUL_STAT.Unite = UNITE.Num '+
              'WHERE (((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+'));';

            QuerySQL.SQL.Add(Sql);
            QuerySQL.Active:=True;

            Flignes.Clear;
            Flignes.Add('Quantités saisies :');
            while QuerySQL.Eof=False do
            begin
              Flignes.Add('  '+ QuerySQL.FieldByName('Statut').AsString+' : '+
                    QuerySQL.FieldByName('Qte_mesu').AsString+' m - '+
                    QuerySQL.FieldByName('Poids_Net').AsString+' kg - '+
                    QuerySQL.FieldByName('Quantité').AsString+' '+QuerySQL.FieldByName('Uni').AsString);
              QuerySQL.Next;
              Flignes.Add('');
            end;

            //Session_FM.Active:=False;
            QuerySQL.Active:=False;

            // on recupere le nombre de raccord global qu'il y a dans le rouleau d'origine + ses bis
            Flignes.Add('Raccords présents (origine+ bis) : ' + Nombre_Raccords_Restant(inttostr(Rouleau)));
            Flignes.Add('');

            Flignes.Add('<ECHAP> FIN DE SAISIE');
            Flignes.Add('<A> ANNULER les Qtes du rouleau et RESAISIR');

            EcritMemo(Flignes);
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            FTag:=SAISIE_OK;
          end
          else
          begin
            // ok aller à la suite pour Siaugues!
            FTag:=SAISIE_OK;
            InputOK;
          end;
        end;
    FIN_SAISIE_ANNULEE :begin // Fin de saisie annulée
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          //SQL_0030
          SQL:='DELETE MOUV_ROUL_STAT WHERE '+
               '(((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+'))';
          ExecuteSQL(True,SQL,0,RecordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;

          FTag:=QST_STATUT; // on retourne sur cet écran (S_04-5)
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('');
          Flignes.Add('Statut Rouleau traité?');
          Flignes.Add('');
          EcritMemo(Flignes);
          AfficheInput;
          Screen.Cursor:=CrDefault;
          ToucheUser:=True;
        end; //case 10
    SAISIE_OK : begin
          Screen.Cursor:=CrHourGlass;
          ToucheUser:=False;
          VaRecopier:=True;
          // verifier que le rouleau est un rouleau coupé
          SQL:='SELECT ROULEAUX.Num, ROULEAUX.Nume_Roul_Orig FROM ROULEAUX '+
              'WHERE (((ROULEAUX.Num)='+ inttostr(Rouleau) +') ' +
              'AND ((ROULEAUX.Nume_Roul_Orig) Is Not Null));';
          ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount>0 then // si le rouleau n'a jamais été coupé, on a aucun controle à recopier!
          begin
          (*
            // verif qu'on a pas dejà recopié les controles lors d'une phase précédente
            SQL:='SELECT CONTROLE.Num, CONTROLE.Num_Roul, CONTROLE.Nume_Phas_Prod, '+
              'CONTROLE.Valide FROM CONTROLE WHERE (((CONTROLE.Num_Roul)='+ inttostr(Rouleau) +') '+
              'AND ((CONTROLE.Nume_Phas_Prod)<>'+PHAS_PROD_Num+') AND ((CONTROLE.Valide)=1));';
            ret:=ExecuteSQL(False,SQL,3, recordCount,Err);
            if Err then
            begin
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              Initialisation;
              Exit;
            end;
            if RecordCount=0 then // aucun controle n'a été recopié sur les phases précédentes si il y a eu
            begin
            *)
              // Verif si dernier rouleau palette
              FLignes.Clear;
              Flignes.Add('Recopier les contrôles de la phase en cours du rouleau d''origine?');
              Flignes.Add('');
              Flignes.Add('NON<0>                  OUI<1>');
              Flignes.Add('');
              EcritMemo(Flignes);
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              (*
            end
            else
            begin // ex : fin de fab revetement du roul coupé en adhésivage
              VaRecopier:=False;
              FTag:=RECOPIE_CONTROLES_FS;
              InputOK;
            end;   *)
          end
          else
          begin
            VaRecopier:=False;
            FTag:=RECOPIE_CONTROLES_FS;
            InputOK;
          end;
        end;
    RECOPIE_CONTROLES_FS : begin
          if VaRecopier then
          begin
            if Recopier_CTRL=True then
            begin
              // Fiches Suiveuse - FS :
              // Cas ou on coupe les rouleaux tres souvent, et qu'on a pas le temps de faire tous
              // les controles sur tous les rouleaux : on propose de recopier TOUS les
              // controles dejà faits sur le rouleau d'origine
              // pk TOUS ? parce que si on deplace le rouleau sur une nouvelle palette, les controles
              // palette suivront aussi
              // pk proposer ? pour les cas ou l'operateur a bien le temps de faire les controles
              // pk le faire à la fin de fabrication ? parce qu'a la mise en fab, tous les controles
              // n'ont pas été faits sur le rouleau d'origine!

              // verifier que le rouleau est un rouleau dejà coupé

              SQL:='SELECT ROULEAUX.Num, ROULEAUX.Nume_Roul_Orig FROM ROULEAUX '+
                  'WHERE (((ROULEAUX.Num)='+ inttostr(Rouleau) +') ' +
                  'AND ((ROULEAUX.Nume_Roul_Orig) Is Not Null));';
              ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              if RecordCount>0 then // si le rouleau n'a jamais été coupé, on a aucun controle à recopier!
              begin
                // RECOPIE TOUS LES CONTROLES DEJA FAITS - ici les controles du rouleau d'origine
                SQL:='SELECT CONTROLE.Num, CONTROLE.Num_Pale, CONTROLE.Num_Roul, '+
                  'CONTROLE.Nume_Phas_Prod, CONTROLE.Date_Ctrl, CONTROLE.Service, '+
                  'CONTROLE.Nom, CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl, CONTROLE.Valeur_Oui_Non, '+
                  'CONTROLE.Valeur, CONTROLE.Val_Mini, CONTROLE.Val_Maxi, CONTROLE.Conforme, '+
                  'CONTROLE.Valide, CONTROLE.Date_Vali, CONTROLE.Commentaire, CONTROLE.Num_Inst, '+
                  'CONTROLE.Ucréa, CONTROLE.DCréa, CONTROLE.Usupp, CONTROLE.Dsupp, '+
                  'CONTROLE.Umodif, CONTROLE.Dmodif FROM (CONTROLE LEFT JOIN '+
                  'PHAS_SPEC_EDIT_INTE_CTRL ON CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl = '+
                  'PHAS_SPEC_EDIT_INTE_CTRL.Num) LEFT JOIN TYPE_CTRL_TYPE ON '+
                  'PHAS_SPEC_EDIT_INTE_CTRL.Num_Type_Ctrl_Type = TYPE_CTRL_TYPE.Num '+
                  'WHERE (((CONTROLE.Num_Roul)='+ret.Strings[1]+') AND ((TYPE_CTRL_TYPE.Copi_Auto)=1));';

                SQL:='SELECT CONTROLE.Num, CONTROLE.Num_Pale, CONTROLE.Num_Roul, '+
                  'CONTROLE.Nume_Phas_Prod, CONTROLE.Service, '+
                  'CONTROLE.Nom, CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl, CONTROLE.Valeur_Oui_Non, '+
                  'CONTROLE.Valeur, CONTROLE.Val_Mini, CONTROLE.Val_Maxi, CONTROLE.Conforme, '+
                  'CONTROLE.Valide, CONTROLE.Commentaire, CONTROLE.Num_Inst, '+
                  'CONTROLE.Ucréa, CONTROLE.Usupp,  '+
                  'CONTROLE.Umodif FROM (CONTROLE LEFT JOIN '+
                  'PHAS_SPEC_EDIT_INTE_CTRL ON CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl = '+
                  'PHAS_SPEC_EDIT_INTE_CTRL.Num) LEFT JOIN TYPE_CTRL_TYPE ON '+
                  'PHAS_SPEC_EDIT_INTE_CTRL.Num_Type_Ctrl_Type = TYPE_CTRL_TYPE.Num '+
                  'WHERE (((CONTROLE.Num_Roul)='+ret.Strings[1]+') AND ((TYPE_CTRL_TYPE.Copi_Auto)=1));';

                ExecuteSQL(False,SQL,1,recordCount,Err);
                if Err then
                begin
                  Screen.Cursor:=CrDefault;
                  ToucheUser:=True;
                  ExecuteV;
                  Exit;
                end;
                if (recordcount>0)then // des controles ont été faits sur le rouleau parent : les recopier sur l'enfant
                begin
                  // on recopie sur le rouleau dont on vient de faire une fin de fab
                  RecopieEnregistements(SQL,'Num_Roul',Inttostr(Rouleau),'Num_Pale',ROULEAUX_Nume_Pale,Err);
                end;
              end;
              // Fin Fiche Suiveuse
            end
            else
            // on ne recopie pas les controles de la phase en qst mais TOUS les controles des phases précédentes (sinon ils vont manquer
            // dans le calcul de la conformité de la palette)
            begin
              // Fiches Suiveuse - FS :
              // verifier que le rouleau est un rouleau dejà coupé
              //TraceDebug('R1-Recopie uniquement des controles des phases précédentes');
              SQL:='SELECT ROULEAUX.Num, ROULEAUX.Nume_Roul_Orig FROM ROULEAUX '+
                  'WHERE (((ROULEAUX.Num)='+ inttostr(Rouleau) +') ' +
                  'AND ((ROULEAUX.Nume_Roul_Orig) Is Not Null));';
              ret:=ExecuteSQL(False,SQL,2, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              //TraceDebug('R2 - recordcount='+inttostr(recordcount));
              if RecordCount>0 then // si le rouleau n'a jamais été coupé, on a aucun controle à recopier!
              begin
                // RECOPIE TOUS LES CONTROLES DEJA FAITS - ici les controles du rouleau d'origine
                SQL:='SELECT CONTROLE.Num, CONTROLE.Num_Pale, CONTROLE.Num_Roul, '+
                  'CONTROLE.Nume_Phas_Prod, CONTROLE.Date_Ctrl, CONTROLE.Service, '+
                  'CONTROLE.Nom, CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl, CONTROLE.Valeur_Oui_Non, '+
                  'CONTROLE.Valeur, CONTROLE.Val_Mini, CONTROLE.Val_Maxi, CONTROLE.Conforme, '+
                  'CONTROLE.Valide, CONTROLE.Date_Vali, CONTROLE.Commentaire, CONTROLE.Num_Inst, '+
                  'CONTROLE.Ucréa, CONTROLE.DCréa, CONTROLE.Usupp, CONTROLE.Dsupp, CONTROLE.Umodif, '+
                  'CONTROLE.Dmodif FROM (CONTROLE LEFT JOIN PHAS_SPEC_EDIT_INTE_CTRL ON '+
                  'CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl = PHAS_SPEC_EDIT_INTE_CTRL.Num) LEFT '+
                  'JOIN TYPE_CTRL_TYPE ON PHAS_SPEC_EDIT_INTE_CTRL.Num_Type_Ctrl_Type = TYPE_CTRL_TYPE.Num '+
                  'WHERE (((CONTROLE.Num_Roul)='+ret.Strings[1]+') AND '+
                  '((CONTROLE.Nume_Phas_Prod)<>'+PHAS_PROD_Num+') AND '+
                  '((TYPE_CTRL_TYPE.Copi_Auto)=1));';

                SQL:='SELECT CONTROLE.Num, CONTROLE.Num_Pale, CONTROLE.Num_Roul, '+
                  'CONTROLE.Nume_Phas_Prod, CONTROLE.Service, '+
                  'CONTROLE.Nom, CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl, CONTROLE.Valeur_Oui_Non, '+
                  'CONTROLE.Valeur, CONTROLE.Val_Mini, CONTROLE.Val_Maxi, CONTROLE.Conforme, '+
                  'CONTROLE.Valide, CONTROLE.Commentaire, CONTROLE.Num_Inst, '+
                  'CONTROLE.Ucréa, CONTROLE.Usupp, CONTROLE.Umodif '+
                  ' FROM (CONTROLE LEFT JOIN PHAS_SPEC_EDIT_INTE_CTRL ON '+
                  'CONTROLE.Num_Phas_Spec_Edit_Inte_Ctrl = PHAS_SPEC_EDIT_INTE_CTRL.Num) LEFT '+
                  'JOIN TYPE_CTRL_TYPE ON PHAS_SPEC_EDIT_INTE_CTRL.Num_Type_Ctrl_Type = TYPE_CTRL_TYPE.Num '+
                  'WHERE (((CONTROLE.Num_Roul)='+ret.Strings[1]+') AND '+
                  '((CONTROLE.Nume_Phas_Prod)<>'+PHAS_PROD_Num+') AND '+
                  '((TYPE_CTRL_TYPE.Copi_Auto)=1));';


                ExecuteSQL(False,SQL,1,recordCount,Err);
                if Err then
                begin
                  Screen.Cursor:=CrDefault;
                  ToucheUser:=True;
                  ExecuteV;
                  Exit;
                end;
                //TraceDebug('R3 - recordcount='+inttostr(recordcount));
                if (recordcount>0)then // des controles ont été faits sur le rouleau parent : les recopier sur l'enfant
                begin
                  // on recopie sur le rouleau dont on vient de faire une fin de fab
                  RecopieEnregistements(SQL,'Num_Roul',Inttostr(Rouleau),'Num_Pale',ROULEAUX_Nume_Pale,Err);
                end;
              end;
            end;
          end;
          FTag:=CREATION_ROULEAU;
          InputOK; // transparent!
        end;
    CREATION_ROULEAU: begin
          // Création du nouveau rouleau
          //insert dans table rouleau Num EXTE-Bis D1 = A1 + "BIS"
          //ROULEAUX_Nume_Exte_BIS:=ROULEAUX_Nume_Exte+' BIS'; // D1
          // modif janvier 08 ... on enlève le BIS!!!


          //ROULEAUX_Nume_Exte_BIS:=ROULEAUX_Nume_Exte; // D1

          // recherche du n° origine mere du rouleau
          SQL:='SELECT ROULEAUX.Nume_Roul_Orig_Mere FROM ROULEAUX WHERE (((ROULEAUX.Num)='+inttostr(Rouleau)+'));';
          ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if trim(ret.strings[0])='' then // le rouleau qu'on veut couper est le rouleau mere
          begin
            ROULEAUX_ORIG_MERE:=inttostr(Rouleau);
            //Modifier le rouleau mere su rouleau mere : les filtres apres seront + faciles!
            SQL:='UPDATE ROULEAUX SET ROULEAUX.Nume_Roul_Orig_Mere = ' +ROULEAUX_ORIG_MERE+
              ' WHERE (((ROULEAUX.Num)='+inttostr(Rouleau)+'));';
            ExecuteSQL(True,SQL,0, recordCount,Err);
            if Err then
            begin
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              Initialisation;
              Exit;
            end;

          end
          else
            ROULEAUX_ORIG_MERE:=ret.Strings[0];

          //SQL_0006
          SQL:='INSERT INTO ROULEAUX (Nume_Exte,Nume_Pale,Nume_Roul_Orig, Nume_Roul_Orig_Mere, '+
              'Ucréa,Dcréa)  VALUES('''+ROULEAUX_Nume_Exte_BIS+
              ''','+ROULEAUX_Nume_Pale+
              ','+inttostr(Rouleau)+' , '+ROULEAUX_ORIG_MERE
              +','''+GetNomMachine+''','''+DateToStr(now)+''')';
          ExecuteSQL(True,SQL,0, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          // on récupère le numero de rouleau créé (D2)
          //SQL_0007
          SQL:='SELECT ROULEAUX.Num FROM ROULEAUX WHERE '+
              '(((ROULEAUX.Nume_Pale)='+ROULEAUX_Nume_Pale+') AND '+
              '((ROULEAUX.Nume_Roul_Orig)='+inttostr(rouleau)+') AND '+
              '((ROULEAUX.Usupp) Is Null) AND ((ROULEAUX.Dsupp) Is Null)) order by rouleaux.num desc';
          ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          if RecordCount=0 then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            GestionErreur('NO RECORD');
            Initialisation;
            exit;
          end;
          ROULEAUX_Num_BIS:=ret.Strings[0]; // D2

          if (A6<>'PH-1') and (A6<>'ME-PH') then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            exit;
          end
          else if A6='ME-PH' then // mm phase de prod
          begin
            // mise en fab du bis -> mouv_roul
            //SQL_0020
            SQL:='INSERT INTO MOUV_ROUL (Nume_Roul,Date_Debu,Heur_Debu,Ucréa,'+
                'Dcréa,Nume_Phas_Prod, Cote_Mach)  VALUES'+
                '('+ROULEAUX_Num_BIS+','''+DateToStr(now)+''','''+timeToStr(time)+
                ''','''+GetnomMachine+''','''+DateToStr(now)+''','+PHAS_PROD_Num+','''+MOUV_ROUL_COTE+''')';
            ExecuteSQL(True,SQL,0, recordCount,Err);
            if Err then
            begin
              Screen.Cursor:=CrDefault;
              ToucheUser:=True;
              Initialisation;
              Exit;
            end;
          end;

          if A6='ME-PH' then    // mm phase de prod
          begin
            // Impression...
            ImpressionEtiquette(True,StrToInt(ROULEAUX_Num_BIS),'',False);
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;

            FTag:=ROULEAU_CREE;
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('N° de Rouleau créé : ');
            Flignes.Add(ROULEAUX_Num_BIS);
            Flignes.Add('');
            Flignes.Add('SUITE <ENTREE>');
            EcritMemo(Flignes);
            Application.ProcessMessages;

            Exit;
          end;

          if A6='PH-1' then   // pas dans la mm phase de prod
          begin
            // 11/10/2010 : remise en cause du système précédent :
            // dorénavant :
            { on coupe le rouleau d'origine, le rouleau bis n'est pas dans la mm phase de prod :
            on a fermé le dernier mouvement du rouleau d'origine
            On demande à l'opérateur dans quel état est le rouleau bis :
              - si il est non conforme (par ex : il est brut et il y a une NC due au client)
              - ou si il est conforme (ex : le client désire traiter uniquement une partie du rouleau)
            Si il est conforme on ne fait rien
            Si il est non conforme, le rouleau va aller en zone rouge : pour que la palette apparaisse
            sur l'état Matière non conforme, on insère un mouvement rouleau bidon, avec comme état non conforme
            On décide de ne pas insérer de mouvment rouleau sur les phases précédentes parce que pas trop d'intéret:
            si on déplace le rouleau bis sur une nouvelle palette, cette palette ne sera pas approvisionnée
            sur l'OF, du coup les phases ne voudront plus rien dire
            et si on laisse le bis sur la palette, on pourra voir que la coupure a bien eu lieu
            sur la phase.
            }
            FTag:=ROULEAU_BIS_ZONE_ROUGE;
            Flignes.Clear;
            Flignes.Add('');
            Flignes.Add('Le rouleau bis va-t-il en zone rouge?');
            Flignes.Add('');
            Flignes.Add('NON <0>                   OUI <1>');
            EcritMemo(Flignes);
            Application.ProcessMessages;
            ToucheUser:=True;
            Application.ProcessMessages;
            exit;




            (* ancienne méthode qui bugait
            if A5='0PHASE' then  // il n'y a jamais eu encore de phase de fab
            begin
              // 11-09-2007 / on se demande bien pourquoi on met le rlx en fab, et en fin de fab...
              // pour nous on ne devrait mme pas mettre un mouvement rlx au bis
              // c'est l'utilisateur qui le mettrait en fab au bon moment, à la mimine
              // réponse 11/10/2010: on estime qu'on vient ici quand le rouleau est non conforme
              // on insere un mouv_roul bidon sur le rouleau bis, pour que, si on le déplace
              // sur une nouvelle palette, la palette soit non conforme et apparaisse
              // en zone rouge dans le flux (état matière non conforme)!
              // S_08
              //INSERT ds MOUV_ROUL:Nume_Roul D2 ,Date_Debu A7 ,Heur_Debu A8 ,
              //Date Fin, Heur_Fin,Nume_Type_Stat,Ucréa,Dcréa
              //SQL_0009
              SQL:='INSERT INTO MOUV_ROUL (Nume_Roul,Date_Debu,Heur_Debu,Date_Fin,'+
                  'Heur_Fin,Nume_Type_Stat,Ucréa,Dcréa)  VALUES'+
                  '('+ROULEAUX_Num_BIS+','''+MOUV_ROUL_Date_Debu+''','''+
                  MOUV_ROUL_Heur_Debu+''','''+DateToStr(now)+''','''+TimeToStr(time)+
                  ''','+InttoStr(Statut_Roul)+','''+GetNomMachine+''','''+DateToStr(now)+''')';
              ExecuteSQL(True,SQL,0, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              //recup du num_mouv_roul (D0) qui vient d'etre cree
              //SQL_0010
              SQL:='SELECT MOUV_ROUL.Num FROM MOUV_ROUL WHERE '+
                  '(((MOUV_ROUL.Nume_Roul)='+ROULEAUX_Num_BIS+') AND '+
                  '((MOUV_ROUL.Usupp) Is Null) AND '+
                  '((MOUV_ROUL.Dsupp) Is Null)) '+
                  'ORDER BY MOUV_ROUL.Date_Fin DESC , MOUV_ROUL.Heur_Fin DESC';
              ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              if RecordCount=0 then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                GestionErreur('NO RECORD');
                Initialisation;
                exit;
              end;
              MOUV_ROUL_Num_BIS:=ret.Strings[0];    //D0
            end
            else if A5='PHASE' then  // il existe déjà une phase
            begin
              //S_09
              // exemple:
              {le Rouleau a 2 phase, et on le coupe uniquement sur la 2eme phase
              on insere un mouv_roul dans la 1ere phase avec le rouleau et le
              rouleau BIS, en mettant les bonnes quantités dans chaque
A FAIRE       : ce qui suit marche avec 1 seule phase précédente, mais
              s'il y en a eu plus de 1 , on fait l'insertion uniquement sur la
              dernière et pas sur les autres!!!!!!
              }
              //recup  PHAS_PROD.Nume_Ordr F0 , PHAS_PROD.Num E9 , MOUV_ROUL.Date_Debu A7, MOUV_ROUL.Heur_Debu A8
              //MOUV_ROUL.Date_Fin F7, MOUV_ROUL.Heur_Fin F8, Mouv_Roul.Num G9, Qte conforme H0
              //SQL_0023
              SQL:='SELECT PHAS_PROD.Nume_Ordr, PHAS_PROD.Num, MOUV_ROUL.Date_Debu, '+
                  'MOUV_ROUL.Heur_Debu, MOUV_ROUL.Date_Fin, MOUV_ROUL.Heur_Fin, '+
                  'MOUV_ROUL.Num, MOUV_ROUL_STAT.Quantité FROM FM_Dern_Mouv_Roul '+
                  'INNER JOIN ((MOUV_ROUL INNER JOIN PHAS_PROD ON '+
                  'MOUV_ROUL.Nume_Phas_Prod = PHAS_PROD.Num) INNER JOIN '+
                  'MOUV_ROUL_STAT ON MOUV_ROUL.Num = MOUV_ROUL_STAT.Num) ON '+
                  'FM_Dern_Mouv_Roul.MaxDeNum = MOUV_ROUL.Num WHERE '+
                  '(((PHAS_PROD.Nume_Ordr)<'+PHAS_PROD_Nume_Ordr+') AND '+
                  '((MOUV_ROUL.Date_Fin) Is Not Null) AND '+
                  '((MOUV_ROUL.Heur_Fin) Is Not Null) AND '+
                  '((MOUV_ROUL.Nume_Roul)='+inttostr(Rouleau)+') AND '+
                  '((MOUV_ROUL.Usupp) Is Null) AND '+
                  '((MOUV_ROUL.Dsupp) Is Null) AND '+
                  '((MOUV_ROUL_STAT.Nume_Sous_Type_Stat)=1)) '+
                  'ORDER BY PHAS_PROD.Nume_Ordr DESC';
              ret:=ExecuteSQL(False,SQL,8, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              if RecordCount=0 then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                GestionErreur('NO RECORD');
                Initialisation;
                exit;
              end;
              PHAS_PROD_Nume_Ordr:=ret.Strings[0];   //F0
              PHAS_PROD_Num:=ret.Strings[1];         //E9
              MOUV_ROUL_Date_Debu:=ret.Strings[2];   //A7
              MOUV_ROUL_Heur_Debu:=ret.Strings[3];   //A8
              MOUV_ROUL_Date_Fin:=ret.Strings[4];    //F7
              MOUV_ROUL_Heur_Fin:=ret.Strings[5];    //F8
              MOUV_ROUL_Num:=ret.Strings[6];         //G9
              MOUV_ROUL_STAT_Quantite:=ret.Strings[7];         //H0
              //Insert dans mouv Roul pour le roul D2
              //Nume_Roul,Date_Debu,Heur_Debu,Date_Fin,Heur_Fin,Nume_Type_Stat,
              //Ucréa,Dcréa,Nume_Phas_Prod
              //SQL_0015
              SQL:='INSERT INTO MOUV_ROUL (Nume_Roul,Date_Debu,Heur_Debu,'+
                  'Date_Fin,Heur_Fin,Nume_Type_Stat,Ucréa,Dcréa,Nume_Phas_Prod)  '+
                  'VALUES('+ROULEAUX_Num_BIS+','''+MOUV_ROUL_Date_Debu+
                  ''','''+MOUV_ROUL_Heur_Debu+''','''+MOUV_ROUL_Date_Fin+
                  ''','''+MOUV_ROUL_Heur_Fin+''','+Inttostr(Statut_Roul)+
                  ','''+GetNomMachine+''','''+DateToStr(now)+''','+PHAS_PROD_Num+')';
              ExecuteSQL(True,SQL,0, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              //recup du num_mouv_roul (D0) qui vient d'etre cree
              //SQL_0010
              SQL:='SELECT MOUV_ROUL.Num FROM MOUV_ROUL WHERE '+
                  '(((MOUV_ROUL.Nume_Roul)='+ROULEAUX_Num_BIS+') AND '+
                  '((MOUV_ROUL.Usupp) Is Null) AND '+
                  '((MOUV_ROUL.Dsupp) Is Null)) '+
                  'ORDER BY MOUV_ROUL.Date_Fin DESC , MOUV_ROUL.Heur_Fin DESC';
              ret:=ExecuteSQL(False,SQL,1, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              if RecordCount=0 then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                GestionErreur('NO RECORD');
                Initialisation;
                exit;
              end;
              MOUV_ROUL_Num_BIS:=ret.Strings[0];    //D0
              //insert dans mouv_roul_stat: Nume_Mouv_Roul,Nume_Sous_Type_Stat,Quantite,Ucréa,Dcréa
              //SQL_0019
              {SQL:='INSERT INTO MOUV_ROUL_STAT (Nume_Mouv_Roul,Nume_Sous_Type_Stat,'+
                  'Quantité,Ucréa,Dcréa,Unite,Nume_Resp_Sous_Type_Stat)  VALUES '+
                  '('+MOUV_ROUL_Num_BIS+','+IntToStr(Statut_Qte_Roul)+','+Qte_Roul+
                  ','''+GetNomMachine+''','''+DateToStr(now)+''','+PALETTE_Unite+',1)';
              }
              SQL:='INSERT INTO MOUV_ROUL_STAT (Nume_Mouv_Roul,Nume_Sous_Type_Stat,'+
                  'Quantité,Ucréa,Dcréa,Unite)  VALUES '+
                  '('+MOUV_ROUL_Num_BIS+','+IntToStr(Statut_Qte_Roul)+','+Qte_Roul+
                  ','''+GetNomMachine+''','''+DateToStr(now)+''','+PALETTE_Unite+')';
              ExecuteSQL(True,SQL,0, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
              //MAJ du mouv_roul origine avec nouveau poids = poids(H0) - poids(E0)
              New_Qte:=StrToFloat(MOUV_ROUL_STAT_Quantite)-StrToFloat(Qte_Roul);
              New_Qte_Str:=FormatFloat('########.###',New_Qte);
              //SQL_0024
              SQL:='UPDATE MOUV_ROUL_STAT SET '+
                  'MOUV_ROUL_STAT.Quantité = '+New_Qte_Str+', '+
                  'MOUV_ROUL_STAT.Umodif = '''+GetNomMachine+''', '+
                  'MOUV_ROUL_STAT.Dmodif = '''+DateToStr(now)+''' '+
                  'WHERE (((MOUV_ROUL_STAT.Nume_Mouv_Roul)='+MOUV_ROUL_Num+') AND '+
                  '((MOUV_ROUL_STAT.Nume_Sous_Type_Stat)=1) AND '+
                  '((MOUV_ROUL_STAT.Usupp) Is Null) AND '+
                  '((MOUV_ROUL_STAT.Dsupp) Is Null))';
              ExecuteSQL(True,SQL,0, recordCount,Err);
              if Err then
              begin
                Screen.Cursor:=CrDefault;
                ToucheUser:=True;
                Initialisation;
                Exit;
              end;
            end;//else if A5='PHASE' then  // il existe déjà une phase
            *)
          end //if A6='PH-1' then   // pas dans la mm phase de prod
          else // on ne devrait jamais rentrer ici!!!
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          ToucheUser:=True;
          Application.ProcessMessages;

          FTag:=ROULEAU_CREE;

        end; // case 12
    ROULEAU_BIS_ZONE_ROUGE : begin
        // statut du mouv_roul sur le bis non conforme en dur!
          SQL:='INSERT INTO MOUV_ROUL (Nume_Roul,Date_Debu,Heur_Debu,Date_Fin,'+
              'Heur_Fin,Nume_Type_Stat,Ucréa,Dcréa)  VALUES'+
              '('+ROULEAUX_Num_BIS+','''+MOUV_ROUL_Date_Debu+''','''+
              MOUV_ROUL_Heur_Debu+''','''+DateToStr(now)+''','''+TimeToStr(time)+
              ''',2,'''+GetNomMachine+''','''+DateToStr(now)+''')';
          ExecuteSQL(True,SQL,0, recordCount,Err);
          if Err then
          begin
            Screen.Cursor:=CrDefault;
            ToucheUser:=True;
            Initialisation;
            Exit;
          end;
          FTag:=ROULEAU_CREE;
          InputOK;
        end;
    ROULEAU_CREE :begin
          ToucheUser:=True;
          Application.ProcessMessages;

          // Impression...
          ImpressionEtiquette(True,StrToInt(ROULEAUX_Num_BIS),'',False);
          FTag:=ROULEAU_CREE;
          Flignes.Clear;
          Flignes.Add('');
          Flignes.Add('N° de Rouleau créé : ');
          Flignes.Add(ROULEAUX_Num_BIS);
          Flignes.Add('');
          Flignes.Add('SUITE <ENTREE>');
          EcritMemo(Flignes);
          Application.ProcessMessages;
        end;
  end;
end;
//


end.
