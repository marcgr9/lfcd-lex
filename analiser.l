/* analizor pentru un MPL */

%{
   /* definitii accesibile in yylex si main */

  #include <string.h>

  struct Element {
    int cod;
    char simbol[20];
    char tip[20];
  };

  struct TS {
    struct Element elemente[50];
    int pozCurenta;
    int codCurent;
  };

  struct FIP {
    int coduri[1000];
    int pozCurenta;
  };

  struct TS tsIds = {.pozCurenta = 0, .codCurent = 0 };
  struct TS tsConstants = {.pozCurenta = 0, .codCurent = 0 };

  struct FIP fip = {.pozCurenta = 0 };
  int liniaCurenta = 1;

  void adaugaFIP(int cod);

  void adaugaTS(int codFIP, char simbol[]);

%}

  /* reguli */
id       [a-zA-Z]+[a-zA-Z_0-9-]*
myInt    [-+]{0,1}(0|[1-9]+[0-9]*)
myString \"[a-zA-Z0-9 $_]*\"
myChar   \'[0-9]\'|\'[a-zA-Z]\'

%%


"apar" { adaugaFIP(5); }
"daca" { adaugaFIP(6); }
"daca nu" { adaugaFIP(7); }
"ia" { adaugaFIP(8); }
"urla" { adaugaFIP(9); }
"tot fa pana" { adaugaFIP(10); }
"opreste te frate" { adaugaFIP(11); }
"SI" { adaugaFIP(12); }
"SAU" { adaugaFIP(13); }
"+" { adaugaFIP(14); }
"++" { adaugaFIP(15); }
"-" { adaugaFIP(16); }
"--" { adaugaFIP(17); }
"*" { adaugaFIP(18); }
"%" { adaugaFIP(19); }
"/" { adaugaFIP(20); }
"+=" { adaugaFIP(21); }
"-=" { adaugaFIP(22); }
"/=" { adaugaFIP(23); }
"=" { adaugaFIP(24); }
"<" { adaugaFIP(25); }
"<=" { adaugaFIP(26); }
"==" { adaugaFIP(27); }
">=" { adaugaFIP(28); }
">" { adaugaFIP(29); }
";" { adaugaFIP(30); }
"," { adaugaFIP(31); }
"[" { adaugaFIP(32); }
"]" { adaugaFIP(33); }
"{" { adaugaFIP(34); }
"}" { adaugaFIP(35); }
"(" { adaugaFIP(36); }
")" { adaugaFIP(37); }
":=" { adaugaFIP(38); }
":" { adaugaFIP(39); }



{id} { adaugaTS(1, yytext); }
{myInt} { adaugaTS(2, yytext); }
{myString} { adaugaTS(3, yytext); }
{myChar} { adaugaTS(4, yytext); }
[ \t]+   /* whitespace */
[\n] {liniaCurenta++;}
.  { printf("ERROR: %s - atom nespecificat la linia %d!\n", yytext, liniaCurenta);
     return -1; }

%%


void adaugaFIP(int cod) {
  fip.coduri[fip.pozCurenta] = cod;
  fip.pozCurenta++;
 }

void adaugaTS(int codFIP, char simbol[]) {
  adaugaFIP(codFIP);

  for(int i = 0; i < tsIds.pozCurenta; i++) {
    if (strcmp(tsIds.elemente[i].simbol, simbol) == 0) return;
  }

  for(int i = 0; i < tsConstants.pozCurenta; i++) {
    if (strcmp(tsConstants.elemente[i].simbol, simbol) == 0) return;
  }

  char tip[20];
  if (codFIP == 1){
    tsIds.elemente[tsIds.pozCurenta].cod = tsIds.codCurent;
    strcpy(tsIds.elemente[tsIds.pozCurenta].simbol, simbol);
    strcpy(tip, "ID");
    strcpy(tsIds.elemente[tsIds.pozCurenta].tip, tip);
    tsIds.codCurent++;
    tsIds.pozCurenta++;
  }


  if(codFIP == 2 || codFIP == 3 || codFIP == 4){
    tsConstants.elemente[tsConstants.pozCurenta].cod = tsConstants.codCurent;
    strcpy(tsConstants.elemente[tsConstants.pozCurenta].simbol, simbol);
    strcpy(tip, "CONSTANT");
    strcpy(tsConstants.elemente[tsConstants.pozCurenta].tip, tip);
    tsConstants.codCurent++;
    tsConstants.pozCurenta++;
  }

 }



int yywrap() {}
int main()
{
  FILE* f;
  char filename[100];
  printf("Fisier: ");
  scanf("%s", filename);
  f = fopen(filename, "r");
  yyin = f;
  if (yylex() == -1) return -1;

  printf("\n----- FIP -----\n");
  for (int i = 0; i < fip.pozCurenta; i++)
    printf("%d ", fip.coduri[i]);

  printf("\n");

  FILE* fIds;
  FILE* fConstants;


  fIds = fopen("tsIds", "w");
  fConstants = fopen("tsConstants", "w");


  printf("\n----- TS - Ids -----\n");
  for (int i = 0; i < tsIds.pozCurenta; i++){
    printf("COD=%d -> SYMBOL: %s\n", i, tsIds.elemente[i].simbol);
    fprintf(fIds, "COD=%d -> SYMBOL: %s\n", i, tsIds.elemente[i].simbol);
  }

  printf("\n----- TS - Constants -----\n");
  for (int i = 0; i < tsConstants.pozCurenta; i++){
    printf("COD=%d -> SYMBOL: %s\n", i, tsConstants.elemente[i].simbol);
    fprintf(fConstants, "COD=%d -> SYMBOL: %s\n", i, tsConstants.elemente[i].simbol);
  }

  fclose(f);
  fclose(fIds);
  fclose(fConstants);

  return 0;
}


