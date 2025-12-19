import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

const publicRoutes = ['/login', '/pending'];

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    if (publicRoutes.some(route => pathname.startsWith(route))) {
        return NextResponse.next();
    }

    return NextResponse.next();
}

export const config = {
    matcher: ['/((?!_next/static|_next/image|favicon.ico|.*\\.png$).*)'],
};
