# ABAP_training
Training ABAP

**Configs uteis**
>- Ajustar layout>opções> Design interativo> Visualização & interação> marcar 2 flags em Controles
- Utilities> Settings> ABAP Editor> Pretty Printer> check ident OR play around


###**Tabela Transparente { exemplos standard }**

| Table | Description                    |
| :-------------: | ------------------------------ |
| `MARA`      | tab de materiais (mm so pp)       |
| `KNA1`   | tab de clientes (sd)     |
| `LFA1`   | tab de fornecedores(mm)     |
| `EKKO`   | documento de compras nivel de cabeçalho ( MM )     |
| `EKPO`   | documento de compras nivel de itens ( MM )     |
| `VBAK`   | header doc. vendas (SO)     |
| `VBAP`   | tens doc vendas (so)     |

| Var name convention | Description                    |
| :-------------: | ------------------------------ |
| `wa_`      | WorkArea pensar em 1 linha       |
| `ti_`   | **Tabela interna {de memoria}**     |
| `s_ `   | valores 'de até' no where é IN por ser range, usando SELECT-OPTIONS     |
| `p_`   | valores de apenas 1 opcao, parametro, no where é =, usando PARAMETERS     |


###**SE38: utilitarios**
>- Programa>Check>Verificacao ampliada
- Goto>Translate

**Basic Workflow:**
- Tables
- Types / Structure
- Workarea
- Internal Table
- Selection screen
- Start of selection event
- Fetch data from a table with openSQL
- Check with subrc to "leave list-processing" or not and sort if success
- Loop at ti into wa to do operations

---
###**TR - Transport Request**
- Objetos $TMP não podem ser transportados. Tu precisa atribuir um pedido de transporte(transport request ou TR) e um pacote valido, então no caso podem.
- Na SE38 vá na barra de menus e clique Ir Para > Entrada de catálogo de objetos (provavelmente estará $TMP como pacote).
-Mude para um pacote válido, eles podem ser criados na SE21.
-Vai pedir para tu criar um número de pedido de transporte, pode ser usado um que já foi criado ou pode criar um por lá mesmo.
- Depois da atribuição é só ativar o código de novo e agora o pedido pode ser lançado na SE10 ou SE09.

-----

###**SE11**
>basic workflow;
Create the table Z**;
put fields (common data element mandt);
data elements to create Z** double click to create;
put a domain and filed labels, double click domain;
choose correct data type for the domain and value range if we gonna use;
activate ctrl_f3 magic stick, choose package or local object;
f3(back) activate others and done;
ate table, check Technical Setting before save.;
Menu to populate the table;
Utilities> Table Contents> Create entries;
Settings>User Params>DataBrowser> Field Label to show our created labels;

pipeline> 2x click forward navigation ate data element;
foreignkeys;
append and includes

---
###**Search helpers and checks**

- helper: edit domain of a data element and add value ranges
checkers: add foreign keys to and field/data element, check generic and delete current entries if has

- Append > add aditional fields without change the original structure of the table
Include(edit>iinclude>insert) > add within first group to be used as KEY(have to be in the beggining of the field list), cannot have another includes into an existing include

- If we mess with field KEYs, like check one for key, activate and after decide not to anymore, will give an error, we need to go to SE14(or Utilities>Database Utility) check save data and "Activate and adjust database"(processing type background if table has millions of records).

---

- COMMENT SELECTION: Ctrl + <
- DOC FOR DEFINITION: Ctrl+F8 (blue icon I)
