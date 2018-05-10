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

**Configs uteis**
> Ajustar layout>opções> Design interativo> Visualização & interação> marcar 2 flags em Controles  
  Utilities> Settings> ABAP Editor> Pretty Printer> check ident OR play around


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

