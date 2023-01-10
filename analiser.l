%{
  #include <string.h>

  struct Element {
    int cod;
    char symbol[20];
    char type[20];
  };

  struct TS {
    struct Element elements[50];
    int currentPosition;
    int currentCode;
  };

  struct PIF {
    int codes[1000];
    int currentPosition;
  };

  struct TS tsIds = {.currentPosition = 0, .currentCode = 0 };
  struct TS tsConstants = {.currentPosition = 0, .currentCode = 0 };

  struct PIF pif = {.currentPosition = 0 };
  int currentLine = 1;

  void addPIF(int cod);

  void addToSymbolTable(int codePIF, char symbol[]);

%}

  /* reguli */
id       [a-zA-Z]+[a-zA-Z_0-9-]*
myInt    [-+]{0,1}(0|[1-9]+[0-9]*)
myString \"[a-zA-Z0-9 $_]*\"
myChar   \'[0-9]\'|\'[a-zA-Z]\'

%%


"apar" { addPIF(5); }
"daca" { addPIF(6); }
"daca nu" { addPIF(7); }
"ia" { addPIF(8); }
"urla" { addPIF(9); }
"tot fa pana" { addPIF(10); }
"opreste te frate" { addPIF(11); }
"SI" { addPIF(12); }
"SAU" { addPIF(13); }
"+" { addPIF(14); }
"++" { addPIF(15); }
"-" { addPIF(16); }
"--" { addPIF(17); }
"*" { addPIF(18); }
"%" { addPIF(19); }
"/" { addPIF(20); }
"+=" { addPIF(21); }
"-=" { addPIF(22); }
"/=" { addPIF(23); }
"=" { addPIF(24); }
"<" { addPIF(25); }
"<=" { addPIF(26); }
"==" { addPIF(27); }
">=" { addPIF(28); }
">" { addPIF(29); }
";" { addPIF(30); }
"," { addPIF(31); }
"[" { addPIF(32); }
"]" { addPIF(33); }
"{" { addPIF(34); }
"}" { addPIF(35); }
"(" { addPIF(36); }
")" { addPIF(37); }
":=" { addPIF(38); }
":" { addPIF(39); }



{id} { addToSymbolTable(1, yytext); }
{myInt} { addToSymbolTable(2, yytext); }
{myString} { addToSymbolTable(3, yytext); }
{myChar} { addToSymbolTable(4, yytext); }
[ \t]+   /* whitespace */
[\n] {currentLine++;}
.  { printf("ERROR: %s - undefined at line %d!\n", yytext, currentLine);
     return -1; }

%%


void addPIF(int cod) {
  pif.codes[pif.currentPosition] = cod;
  pif.currentPosition++;
 }

void addToSymbolTable(int codePIF, char symbol[]) {
  addPIF(codePIF);

  for(int i = 0; i < tsIds.currentPosition; i++) {
    if (strcmp(tsIds.elements[i].symbol, symbol) == 0) return;
  }

  for(int i = 0; i < tsConstants.currentPosition; i++) {
    if (strcmp(tsConstants.elements[i].symbol, symbol) == 0) return;
  }

  char type[20];
  if (codePIF == 1){
    tsIds.elements[tsIds.currentPosition].cod = tsIds.currentCode;
    strcpy(tsIds.elements[tsIds.currentPosition].symbol, symbol);
    strcpy(type, "ID");
    strcpy(tsIds.elements[tsIds.currentPosition].type, type);
    tsIds.currentCode++;
    tsIds.currentPosition++;
  }


  if(codePIF == 2 || codePIF == 3 || codePIF == 4){
    tsConstants.elements[tsConstants.currentPosition].cod = tsConstants.currentCode;
    strcpy(tsConstants.elements[tsConstants.currentPosition].symbol, symbol);
    strcpy(type, "CONSTANT");
    strcpy(tsConstants.elements[tsConstants.currentPosition].type, type);
    tsConstants.currentCode++;
    tsConstants.currentPosition++;
  }

 }



int yywrap() {}
int main()
{
  FILE* f;
  char filename[100];
  printf("File: ");
  scanf("%s", filename);
  f = fopen(filename, "r");
  yyin = f;
  if (yylex() == -1) return -1;

  printf("\n----- PIF -----\n");
  for (int i = 0; i < pif.currentPosition; i++)
    printf("%d ", pif.codes[i]);

  printf("\n");

  FILE* fIds;
  FILE* fConstants;


  fIds = fopen("tsIds", "w");
  fConstants = fopen("tsConstants", "w");


  printf("\n----- Ids -----\n");
  for (int i = 0; i < tsIds.currentPosition; i++){
    printf("CODE=%d -> SYMBOL: %s\n", i, tsIds.elements[i].symbol);
    fprintf(fIds, "CODE=%d -> SYMBOL: %s\n", i, tsIds.elements[i].symbol);
  }

  printf("\n----- Constants -----\n");
  for (int i = 0; i < tsConstants.currentPosition; i++){
    printf("CODE=%d -> SYMBOL: %s\n", i, tsConstants.elements[i].symbol);
    fprintf(fConstants, "CODE=%d -> SYMBOL: %s\n", i, tsConstants.elements[i].symbol);
  }

  fclose(f);
  fclose(fIds);
  fclose(fConstants);

  return 0;
}


