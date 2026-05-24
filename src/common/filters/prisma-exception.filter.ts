// import { Catch, ExceptionFilter, ArgumentsHost } from '@nestjs/common';
// import { HttpStatus } from '@nestjs/common';
// import { Prisma } from '@prisma/client';
// import { Response } from 'express';

// @Catch(Prisma.PrismaClientKnownRequestError)
// export class PrismaExceptionFilter implements ExceptionFilter {
//   catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
//     const ctx = host.switchToHttp();
//     const response = ctx.getResponse<Response>();

//     let status = HttpStatus.INTERNAL_SERVER_ERROR;
//     let errorCode = 'INTERNAL_SERVER_ERROR';
//     let errorMessage = 'An unexpected database error occurred';

//     switch (exception.code) {
//       case 'P2002': // Unique constraint failed
//         status = HttpStatus.CONFLICT;
//         errorCode = 'UNIQUE_CONSTRAINT_FAILED';
//         errorMessage = `A record with this ${exception.meta?.target} already exists.`;
//         break;
//       case 'P2003': // Foreign key constraint failed
//         status = HttpStatus.BAD_REQUEST;
//         errorCode = 'FOREIGN_KEY_CONSTRAINT_FAILED';
//         errorMessage = 'Related record not found or dependency violation.';
//         break;
//       case 'P2025': // Record not found
//         status = HttpStatus.NOT_FOUND;
//         errorCode = 'RECORD_NOT_FOUND';
//         errorMessage = (exception.meta?.cause as string) || 'Record not found.';
//         break;
//       default:
//         break;
//     }

//     response.status(status).json({
//       statusCode: status,
//       errorCode,
//       message: errorMessage,
//       timestamp: new Date().toISOString(),
//       path: ctx.getRequest().url,
//     });
//   }
// }
