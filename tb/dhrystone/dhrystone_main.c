/*
* @Author: Ruige Lee
* @Date:   2021-02-01 11:27:23
* @Last Modified by:   Ruige Lee
* @Last Modified time: 2021-03-18 16:04:12
*/
// See LICENSE for license details.

//**************************************************************************
// Dhrystone bencmark
//--------------------------------------------------------------------------
//
// This is the classic Dhrystone synthetic integer benchmark.
//

#pragma GCC optimize ("no-inline")

#include "dhrystone.h"

#include "util.h"

#include <alloca.h>

/* Global Variables: */

Rec_Pointer     Ptr_Glob,
								Next_Ptr_Glob;
int             Int_Glob;
Boolean         Bool_Glob;
char            Ch_1_Glob,
								Ch_2_Glob;
int             Arr_1_Glob [50];
int             Arr_2_Glob [50] [50];

Enumeration     Func_1 ();
	/* forward declaration necessary since Enumeration may not simply be int */

#ifndef REG
				Boolean Reg = false;
#define REG
				/* REG becomes defined as empty */
				/* i.e. no register variables   */
#else
				Boolean Reg = true;
#undef REG
#define REG register
#endif


long            Begin_Time,
								End_Time,
								User_Time;
long            Microseconds,
								Dhrystones_Per_Second;

/* end of variables for time measurement */


int main (int argc, char** argv)
/*****/
	/* main program, corresponds to procedures        */
	/* Main and Proc_0 in the Ada version             */
{
				One_Fifty       Int_1_Loc;
	REG   One_Fifty       Int_2_Loc;
				One_Fifty       Int_3_Loc;
	REG   char            Ch_Index;
				Enumeration     Enum_Loc;
				Str_30          Str_1_Loc;
				Str_30          Str_2_Loc;
	REG   int             Run_Index;
	REG   int             Number_Of_Runs;

	/* Arguments */
	Number_Of_Runs = 500;

	/* Initializations */

	Next_Ptr_Glob = (Rec_Pointer) alloca (sizeof (Rec_Type));
	Ptr_Glob = (Rec_Pointer) alloca (sizeof (Rec_Type));

	Ptr_Glob->Ptr_Comp                    = Next_Ptr_Glob;
	Ptr_Glob->Discr                       = Ident_1;
	Ptr_Glob->variant.var_1.Enum_Comp     = Ident_3;
	Ptr_Glob->variant.var_1.Int_Comp      = 40;
	strcpy (Ptr_Glob->variant.var_1.Str_Comp, 
					"DHRYSTONE PROGRAM, SOME STRING");
	strcpy (Str_1_Loc, "DHRYSTONE PROGRAM, 1'ST STRING");

	Arr_2_Glob [8][7] = 10;
				/* Was missing in published program. Without this statement,    */
				/* Arr_2_Glob [8][7] would have an undefined value.             */
				/* Warning: With 16-Bit processors and Number_Of_Runs > 32000,  */
				/* overflow may occur for this array element.                   */

	printf("\n");
	printf("Dhrystone Benchmark, Version %s\n", Version);
	if (Reg)
	{
		printf("Program compiled with 'register' attribute\n");
	}
	else
	{
		printf("Program compiled without 'register' attribute\n");
	}
	printf("Using TB, HZ=50MHz\n");
	printf("\n");


	volatile uint8_t* timer = (uint8_t*)(0x20000008);
	printf("Trying %d runs through Dhrystone:\n", Number_Of_Runs);
	
	*timer = 1;


	// while (!Done) 
	{


		/***************/
		/* Start timer */
		/***************/

		// setStats(1);
		// Start_Timer();




		for (Run_Index = 1; Run_Index <= Number_Of_Runs; ++Run_Index)
		{

			// printf( "Run_Index = %d \n", Run_Index );
			Proc_5();
			Proc_4();

			/* Ch_1_Glob == 'A', Ch_2_Glob == 'B', Bool_Glob == true */
			Int_1_Loc = 2;
			Int_2_Loc = 3;
			strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 2'ND STRING");
			Enum_Loc = Ident_2;
			Bool_Glob = ! Func_2 (Str_1_Loc, Str_2_Loc);
			/* Bool_Glob == 1 */
			while (Int_1_Loc < Int_2_Loc)  /* loop body executed once */
			{
				Int_3_Loc = 5 * Int_1_Loc - Int_2_Loc;
				/* Int_3_Loc == 7 */
				Proc_7 (Int_1_Loc, Int_2_Loc, &Int_3_Loc);
				/* Int_3_Loc == 7 */
				Int_1_Loc += 1;
			} /* while */
			/* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
			Proc_8 (Arr_1_Glob, Arr_2_Glob, Int_1_Loc, Int_3_Loc);

			/* Int_Glob == 5 */
			Proc_1 (Ptr_Glob);

			for (Ch_Index = 'A'; Ch_Index <= Ch_2_Glob; ++Ch_Index)
			/* loop body executed twice */
			{
				if (Enum_Loc == Func_1 (Ch_Index, 'C'))
				/* then, not executed */
				{
					Proc_6 (Ident_1, &Enum_Loc);

					strcpy (Str_2_Loc, "DHRYSTONE PROGRAM, 3'RD STRING");
					Int_2_Loc = Run_Index;
					Int_Glob = Run_Index;
				}
			}
			/* Int_1_Loc == 3, Int_2_Loc == 3, Int_3_Loc == 7 */
			Int_2_Loc = Int_2_Loc * Int_1_Loc;
			Int_1_Loc = Int_2_Loc / Int_3_Loc;
			Int_2_Loc = 7 * (Int_2_Loc - Int_3_Loc) - Int_1_Loc;
			/* Int_1_Loc == 1, Int_2_Loc == 13, Int_3_Loc == 7 */
			Proc_2 (&Int_1_Loc);

			/* Int_1_Loc == 5 */

		} /* loop "for Run_Index" */

		/**************/
		/* Stop timer */
		/**************/

		// Stop_Timer();
		// setStats(0);
		*timer = 0;

		User_Time = End_Time - Begin_Time;

		// if (User_Time < Too_Small_Time)
		// {
		// 	tb_printf("Measured time too small to obtain meaningful results\n");
		// 	Number_Of_Runs = Number_Of_Runs * 10;
		// 	tb_printf("\n");
		// } 
		// else 
		// {
		// 	Done = true;			
		// }

	}

	// printf("Final values of the variables used in the benchmark:\n");
	// printf("\n");
	// printf("Int_Glob:            %d\n", Int_Glob);
	// printf("        should be:   %d\n", 5);
	// printf("Bool_Glob:           %d\n", Bool_Glob);
	// printf("        should be:   %d\n", 1);
	// printf("Ch_1_Glob:           %c\n", Ch_1_Glob);
	// printf("        should be:   %c\n", 'A');
	// printf("Ch_2_Glob:           %c\n", Ch_2_Glob);
	// printf("        should be:   %c\n", 'B');
	// printf("Arr_1_Glob[8]:       %d\n", Arr_1_Glob[8]);
	// printf("        should be:   %d\n", 7);
	// printf("Arr_2_Glob[8][7]:    %d\n", Arr_2_Glob[8][7]);
	// printf("        should be:   Number_Of_Runs + 10\n");
	// printf("Ptr_Glob->\n");
	// printf("  Ptr_Comp:          %d\n", (long) Ptr_Glob->Ptr_Comp);
	// printf("        should be:   (implementation-dependent)\n");
	// printf("  Discr:             %d\n", Ptr_Glob->Discr);
	// printf("        should be:   %d\n", 0);
	// printf("  Enum_Comp:         %d\n", Ptr_Glob->variant.var_1.Enum_Comp);
	// printf("        should be:   %d\n", 2);
	// printf("  Int_Comp:          %d\n", Ptr_Glob->variant.var_1.Int_Comp);
	// printf("        should be:   %d\n", 17);
	// printf("  Str_Comp:          %s\n", Ptr_Glob->variant.var_1.Str_Comp);
	// printf("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
	// printf("Next_Ptr_Glob->\n");
	// printf("  Ptr_Comp:          %d\n", (long) Next_Ptr_Glob->Ptr_Comp);
	// printf("        should be:   (implementation-dependent), same as above\n");
	// printf("  Discr:             %d\n", Next_Ptr_Glob->Discr);
	// printf("        should be:   %d\n", 0);
	// printf("  Enum_Comp:         %d\n", Next_Ptr_Glob->variant.var_1.Enum_Comp);
	// printf("        should be:   %d\n", 1);
	// printf("  Int_Comp:          %d\n", Next_Ptr_Glob->variant.var_1.Int_Comp);
	// printf("        should be:   %d\n", 18);
	// printf("  Str_Comp:          %s\n",
	// 															Next_Ptr_Glob->variant.var_1.Str_Comp);
	// printf("        should be:   DHRYSTONE PROGRAM, SOME STRING\n");
	// printf("Int_1_Loc:           %d\n", Int_1_Loc);
	// printf("        should be:   %d\n", 5);
	// printf("Int_2_Loc:           %d\n", Int_2_Loc);
	// printf("        should be:   %d\n", 13);
	// printf("Int_3_Loc:           %d\n", Int_3_Loc);
	// printf("        should be:   %d\n", 7);
	// printf("Enum_Loc:            %d\n", Enum_Loc);
	// printf("        should be:   %d\n", 1);
	// printf("Str_1_Loc:           %s\n", Str_1_Loc);
	// printf("        should be:   DHRYSTONE PROGRAM, 1'ST STRING\n");
	// printf("Str_2_Loc:           %s\n", Str_2_Loc);
	// printf("        should be:   DHRYSTONE PROGRAM, 2'ND STRING\n");
	// printf("\n");


	// Microseconds = ((User_Time / Number_Of_Runs) * Mic_secs_Per_Second) / HZ;
	// Dhrystones_Per_Second = (HZ * Number_Of_Runs) / User_Time;

	// tb_printf("Microseconds for one run through Dhrystone: %ld\n", Microseconds);
	// tb_printf("Dhrystones per Second:                      %ld\n", Dhrystones_Per_Second);

	volatile uint8_t* COTRL = (uint8_t*)(0x20000010);
	*COTRL = 1;

	return 0;
}


Proc_1 (Ptr_Val_Par)
/******************/

REG Rec_Pointer Ptr_Val_Par;
		/* executed once */
{
	REG Rec_Pointer Next_Record = Ptr_Val_Par->Ptr_Comp;  
																				/* == Ptr_Glob_Next */
	/* Local variable, initialized with Ptr_Val_Par->Ptr_Comp,    */
	/* corresponds to "rename" in Ada, "with" in Pascal           */
	
	structassign (*Ptr_Val_Par->Ptr_Comp, *Ptr_Glob); 
	Ptr_Val_Par->variant.var_1.Int_Comp = 5;
	Next_Record->variant.var_1.Int_Comp 
				= Ptr_Val_Par->variant.var_1.Int_Comp;
	Next_Record->Ptr_Comp = Ptr_Val_Par->Ptr_Comp;
	Proc_3 (&Next_Record->Ptr_Comp);
		/* Ptr_Val_Par->Ptr_Comp->Ptr_Comp 
												== Ptr_Glob->Ptr_Comp */
	if (Next_Record->Discr == Ident_1)
		/* then, executed */
	{
		Next_Record->variant.var_1.Int_Comp = 6;
		Proc_6 (Ptr_Val_Par->variant.var_1.Enum_Comp, 
					 &Next_Record->variant.var_1.Enum_Comp);
		Next_Record->Ptr_Comp = Ptr_Glob->Ptr_Comp;
		Proc_7 (Next_Record->variant.var_1.Int_Comp, 10, 
					 &Next_Record->variant.var_1.Int_Comp);
	}
	else /* not executed */
	{
		structassign (*Ptr_Val_Par, *Ptr_Val_Par->Ptr_Comp);
	}
} /* Proc_1 */


Proc_2 (Int_Par_Ref)
/******************/
		/* executed once */
		/* *Int_Par_Ref == 1, becomes 4 */

One_Fifty   *Int_Par_Ref;
{
	One_Fifty  Int_Loc;  
	Enumeration   Enum_Loc;

	Int_Loc = *Int_Par_Ref + 10;
	do /* executed once */
	{
		if (Ch_1_Glob == 'A')
			/* then, executed */
		{
			Int_Loc -= 1;
			*Int_Par_Ref = Int_Loc - Int_Glob;
			Enum_Loc = Ident_1;
		} /* if */	
	}
	while (Enum_Loc != Ident_1); /* true */
} /* Proc_2 */


Proc_3 (Ptr_Ref_Par)
/******************/
		/* executed once */
		/* Ptr_Ref_Par becomes Ptr_Glob */

Rec_Pointer *Ptr_Ref_Par;

{
	if (Ptr_Glob != Null)
		/* then, executed */
	{
		*Ptr_Ref_Par = Ptr_Glob->Ptr_Comp;		
	}

	Proc_7 (10, Int_Glob, &Ptr_Glob->variant.var_1.Int_Comp);
} /* Proc_3 */


Proc_4 () /* without parameters */
/*******/
		/* executed once */
{
	Boolean Bool_Loc;

	Bool_Loc = Ch_1_Glob == 'A';
	Bool_Glob = Bool_Loc | Bool_Glob;
	Ch_2_Glob = 'B';
} /* Proc_4 */


Proc_5 () /* without parameters */
/*******/
		/* executed once */
{
	Ch_1_Glob = 'A';
	Bool_Glob = false;
} /* Proc_5 */


