# ABAP_training

Apanhado de anotações e informações gerais sobre ABAP

### Links úteis:
[ABAP101](http://abap101.com/)  
[ABAP Zombies](http://www.abapzombie.com/)  
[HANA Brasil: links uteis](http://hanabrasil.com.br/links/)  
[ABAP OO beginners](http://www.beginners-sap.com/object-orientation-abap/)  
[Help SAP](https://help.sap.com/)  
[SAP Community](https://www.sap.com/community.html)  
[Simulados ABAP](https://www.daypo.net/search.php?t=abap)  
[O que continuar a estudar como um App Dev](https://blogs.sap.com/2017/01/19/what-should-an-abaper-continue-to-learn-as-an-application-developer/)  
[Por que programação funcional?](https://stackoverflow.com/questions/36504/why-functional-languages)  
[Programação funcional em ABAP](https://blogs.sap.com/2015/04/09/funtional-programming-in-abap/)  
[Wiki de codigos possivelmente úteis](http://rosettacode.org/wiki/Rosetta_Code)  
[SAPTech tutorials - Custom BAPI ex.](http://saptechnical.com/Tutorials/BAPI/CustomBAPICreation/page1.htm)  
[BAPI stepbystep.pdf](https://archive.sap.com/kmuuid2/200dd1cc-589e-2910-98a9-bb2c48b78dfa/BAPI%20Step-by-Step.pdf)  
[Amarm ABAP Tutorials](http://www.amarmn.com/p/abap-tutorials.html)  
[SE80 uk](http://www.se80.co.uk/)  
[ABAP Junior - Enhancements](http://abapjuniores.blogspot.com.br/2011/11/enhancements-modificando-o-standard.html)  
[AbapBrasil Base de conhecimento](https://abapbrasil.wordpress.com/category/abap/module-pool-programas-on-line/)  

[ABAP on Eclipse for S4H](https://sapyard.com/abap-on-sap-hana-part-ii/)  


**Configs uteis**
> Ajustar layout>opções> Design interativo> Visualização & interação> marcar 2 flags em Controles  
  Utilities> Settings> ABAP Editor> Pretty Printer> check ident OR play around  
  
**Some Debug info**
> F1 > info tecnicas, sempre útil  
  BREAK-POINT - ativa debug em certa linha de um programa  
  /h  - ativa debug  
  f7 ate o programa z  
  f5 step para executar e entrar nos includes/performs  
  f6 steps de execução sem entrar a fundo  
  
**BATCH-INPUT**
> Serve para cadastros e nao relatorios, alterar varios users ao mesmo tempo por ex., automatizando algum fluxo para commitar no banco  
  Utiliza telas como fluxo e usar apenas quando não houver BAPI  
  Memorizar a estrutura BDCDATA  
  tcodes: LSMW(funcional) / SHDB(abap)  
  New recording > nome_carga, TCODE >  
  
**BAPI, BADI**
> **BAPI stands for Business Application Programming Interface, WebService.**   
  BAPI - It is nothing, but a FM which is used to load the data into SAP system. The data may be from the Legacy system. They all are RFCs.  
  **BADI stands for Business Add-Ins, are a new SAP enhancement technique based on ABAP Objects**  
  BADI - They are the enhancement which can be applied to the standard SAP program as per the business requirement. BADI are the newer version of user exits which uses ABAP OOPs concept.  
  
  > - Business Add-Ins are a new SAP enhancement technique based on ABAP Objects. They can be inserted into the SAP System to accommodate user requirements too specific to be included in the standard delivery. Since specific industries often require special functions, SAP allows you to predefine these points in your software.  
As with customer exits two different views are available:  
In the definition view, an application programmer predefines exit points in a source that allow specific industry sectors, partners, and customers to attach additional software to standard SAP source code without having to modify the original object.  
In the implementation view, the users of Business Add-Ins can customize the logic.  
BAPI (Business Application Programming Interface) is a set of interfaces to object-oriented programming methods that enable a programmer to integrate third-party software into the proprietary R/3 product from SAP.BAPI are implemented and stored in the the R/3 system as remote function call (RFC) modules.  
  
  > - BADI is just an object-oriented version of user-exit. Instead of entering program code into some function module (as in customer-exit), you define some class which has to implement predefined methods and those methods are fired at predefined points just like an old user-exit. Some BADI can have multiple independent implementations which is much better for software deployment as several developers can implement the same BADI independently.  
To understand BAPIs, we must know that there are 2 things. One is the SAP Object Repository of the Business Object Repository (BOR) and the Function Builder.  
Now the business objects with their business processes and business data, reside in the BOR, with the corresponding BAPI. the implementation of this BAPI resides in the function builder. Any external world (non SAP) programs or legacy systems can access the business processes or data of any business object in the BOR, thru the process of invoking the BAPI implementation of the BAPI for this business object.  
Thus we can access a business object.  
So we can say that a BAPI is a process that allows third party s/w or non SAP programs to access SAP Business object data and processes.  

### **Tabela Transparente { exemplos standard }**

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
| `cl_`   `_cl`   | Classe; Classe ref      |
| `if_`  `_if`    | Interface; Interface ref      |
| `fs_`      | FieldSymbols, nossos ponteiros       |

### Tabela Interna
We Have 3 types of Internal Tables  

| Table             | Description                    | Access |
| :-------------: | ------------------------------ | ------------------------------ |
| `STANDARD`      | Similar to a Database Table | Accessible by row & keys       |
| `SORTED`   | Data is always sorted by the specified keys | Accessible by row & keys     |
| `HASHED`   | Unique keys only | Accessible by keys only (often Fastest way to access)    |


### **SE38: utilitarios**
>Programa>Check>Verificacao ampliada  
Goto>Translate

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
### **TR - Transport Request**
- Objetos $TMP não podem ser transportados. Tu precisa atribuir um pedido de transporte(transport request ou TR) e um pacote valido, então no caso podem.
- Na SE38 vá na barra de menus e clique Ir Para > Entrada de catálogo de objetos (provavelmente estará $TMP como pacote).
-Mude para um pacote válido, eles podem ser criados na SE21.
-Vai pedir para tu criar um número de pedido de transporte, pode ser usado um que já foi criado ou pode criar um por lá mesmo.
- Depois da atribuição é só ativar o código de novo e agora o pedido pode ser lançado na SE10 ou SE09.

-----

### **SE11**
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
### **Search helpers and checks**

- helper: edit domain of a data element and add value ranges
checkers: add foreign keys to and field/data element, check generic and delete current entries if has

- Append > add aditional fields without change the original structure of the table
Include(edit>iinclude>insert) > add within first group to be used as KEY(have to be in the beggining of the field list), cannot have another includes into an existing include

- If we mess with field KEYs, like check one for key, activate and after decide not to anymore, will give an error, we need to go to SE14(or Utilities>Database Utility) check save data and "Activate and adjust database"(processing type background if table has millions of records).

---

- COMMENT SELECTION: Ctrl + <
- DOC FOR DEFINITION: Ctrl+F8 (blue icon I)  

---
Dicas sobre field-symbols  
Por: Fabio Kazunari  

- Use field-symbols dentro de LOOPs. Saiba exatamente onde estão as teclas < e > do seu teclado para não ter preguiça de declará-los
- Caso queira reaproveitar um field-symbol depois de um LOOP, não o faça. Você irá esquecer cedo ou tarde o uso do UNASSIGN. Declare outro field-symbol para evitar erros.
- Se você declarou um field-symbol globalmente no top include, deixe seu celular ligado durante a noite pois você pode precisar… ou melhor… alguém precisar de você
- Caso você precise de mais de um field-symbol para a mesma tabela interna, dê nomes ilustrativos ao invés de e . Ainda evite copy & paste deste código.
- Caso esteja usando ABAP Objects, sempre confiro a definição da tabela interna que usarei. Caso ela seja READ-ONLY, evito o field-symbol pois ele é mais poderoso o primeiro.
> Meu estilo de programação faz uso extensivo de field-symbols. Eu raramente populo uma tabela interna registro por registro ou uso alguma estrutura auxiliar para modificá-la. Como sempre estou usando métodos pequenos, nunca faço o uso de field-symbols globais que possam ser perigosamente reaproveitados por alguém que dê manutenção no código. Caso eu veja algum field-symbol global usado num só FORM ou método, eu o movo para uma declaração local.

[Fonte](http://abap101.com/2013/03/25/field-symbols-sao-suas-vantagens-por-fabio-kazunari/)

---

### Some useful tech info:

Access to nested internal tables using field symbols usually increase performance.  

A key field in a database table uniquely identifies a data record.  
The OPENSQL statements are converted into database-specific statements by the database interface.  
A secondar index for non-key field generally works like a primary index for key fields.  
You can select from several databases tables using a database view or a join.  

Main reasons for using update techniques:
- To relieve the load on the dialog work processes.
- To create reusable modules for database changes.
- To collect database change request from several dialog step in order to processthem or delete them together

Before modify an SAP program, we need to watch out for:
- We can perform the modification immediately if we set the global setting for system modifiability to "Modifiable". RZ11.
- If a user has modified an SAP object and SAP delivers a new version of the object in a release upgrade of Support Package, the modified object must be adjusted during the upgrade.
- Before we can change the program, we must request a key for the object in the SAP New Web front-end

Call the ABAP command COMMIT WORK when using update technique.  

Sub objects that an SAP enhancement can contain:
- Append structures
- Screen exits
- Menu exits.
- Function module exits.

This happens if we have a CALL TRANSACTION statement:
- The called transaction is processed in a separated database LUW.
- Another internal session is opened for the transaction.
- Processing of the calling program will be continued at the end of the transaction.
- The update process triggered by the called transaction can be executed async or sync, as required.

SE24: If we have a "Singleton Pattern", we must ensure that only one obj can be created from a cl_singleton class. So:
- The singleton class must have a class method implemented in which the CREATE OBJECT call is programmed for this one object.
- In the isngleton class, there must be an even defined that is triggered when the first and only obj is created and also prevents further objects of this class from being created.
- The CREATE OBJECT call for this one obj can take place in the class constructor of the singleton class.
- The singleton class must have an instance method implemented in which the CREATE OBJECT call is programmed for this one obj.
- The singleton class must have the addition CREATE PRIVATE in the definition part.

In program P, the SUBMIT statement is used to call report R. We can pass data from P to R:
- by passing parameters using additions in the SUBMIT statement.
- Using the ABAP memory.
- Using the SET/GET parameters.

Constructor(instance) is:
- An instance method for initializing the attributes of an object; It is automatically called by the system during CREATE OBJECT.

We are writing a transaction to update a database table. The program MUST contain:
- A call for an update function module in the case of time-consuming changes.
- A call for ENQUEUE/DEQUEUE function modules.
- An AUTHORITY-CHECK statement.

We use the reference ME within a class to call attributes and methods of the class itself.  

We can undo database changes executed beforehand in a dialog:
- Performing a ROLLBACK WORK.
- Output a termination message. (ABORT, X)

The definition of internal tables without header lines and Typing with TYPE to ABAP Dictionary types are allowed within class definitions.  

Some statements about interfaces:
- Using interfaces you can simulate multiple inheritance.
- A client (caller) can use interface reference to access all methods of the interfaces and thus achive polymorphism behavior
- Interfaces actually stand for an interface (protocol) between a client (interface ueer) and a server (Implementing class).

Statements allowed while working with an internal table of the type SORTED:
- COLLECT
- READ

If we are using async update, the statement COMMIT WORK is not required because it is executed implicity after each screen change at dialog program.  

Dispatcher is the component of an application server that controls the data traffic between a work process and a presentation server.  

START-OF-SELECTION event generate lists.  

PBO means process before output (of selection screen)  
PBO modules are executed before the screen is displayed.  
PBO can be compared with INITIALIZATION and AT SELECTION-SCREEN OUTPUT events and all at selection screen events.  
  
PAI means Process after input.  
PAI modules are executed after any input like pushing the button or pressing enter.  
PAI can be compared with start-of-selection and all the other events.  

Find BADI in a minute:
1. Go to the TCode SE24 and enter CL_EXITHANDLER as object type.
2. In 'Display' mode, go to 'Methods' tab.
3. Double click the method 'Get Instance' to display it source code.
4. Set a breakpoint on 'CALL METHOD cl_exithandler=>get_class_name_by_interface'.
5. Then run your transaction.
6. The screen will stop at this method.
7. Check the value of parameter 'EXIT_NAME'. It will show you the BADI for that transaction.


Para adicionar função customizada em um fullscreen ALV é necessário copiar um 'GUI Status' como STANDARD na SE90 ou SE41, de um programa standard como SAPLSALV ou SAPLKKBL, modifica-lo dentro do report Z adicionando a função e icone, depois adiciona-lo no abap set_screen_status do salv table.


Bug in SE80 width> Go to SE16, edit the table RSEUMOD, for your user, increase the value of WIDTH to say 200 and save, then try SE80 again.
(SE16: Display and mark the records you want to change or delete, show detail view (F7). Enter /h to activate debugger, ENTER. You find yourself in debugger in form set_status_val. Change the value of variable code to 'DELE' for deletion, 'EDIT' for change or 'INSR', then F8 to continue. Now the respective function is active. )


ENHANCEMENT-POINT static  = only for declarations  
ENHANCEMENT-POINT         = code in the block  
ENHANCEMENT-POINT section = if implemented a Z, it ignores standard and execute our Z implementation  


add GUI PF STATUS in standard, implicit  
SET PF-STATUS 'STANDARD' OF PROGRAM 'SAPLKKBL' EXCLUDING lv_extab."#EC *.  


SAP Icons: run program RSTXICON  

#Find enhancement and project name of an User exit:  
table MODSAP to get enhancement if you have function exit (e.g. EXIT_SAPLV60B_010)  
table MODACT give field member(enhancement)  


program RPR_ABAP_SOURCE_SCAN  
you can specify a text string in the selection screen.  
try to search with 'UPDATE Z', 'DELETE Z' keywords. Also give package if you know it.  
