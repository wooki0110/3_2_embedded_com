/*
 * Stage6.h
 *
 *  Created on: 2022. 10. 24.
 *      Author: KBF
 */

#ifndef SRC_STAGE7_H_
#define SRC_STAGE7_H_

void Stage7(complex *output, complex *input)
{
	int n;
	for (n=0;n<64;n++)
			{
				output[2*n]=add_cal(input[2*n],input[2*n+1]);
				output[2*n+1]=sub_cal(input[2*n],input[2*n+1]);
			}
}

#endif /* SRC_STAGE7_H_ */
